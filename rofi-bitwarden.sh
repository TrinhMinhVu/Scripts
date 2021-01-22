#!/bin/bash
# Rofi extension for BitWarden-cli
NAME="$(basename "$0")"
VERSION="0.4"
DEFAULT_CLEAR=5
BW_HASH=

# Options
CLEAR=$DEFAULT_CLEAR # Clear password after N seconds (0 to disable)
SHOW_PASSWORD=no # Show part of the password in the notification
AUTO_LOCK=900 # 15 minutes, default for bitwarden apps

# Holds the available items in memory
ITEMS=

# Stores which command will be used to emulate keyboard type
AUTOTYPE_MODE=

# Stores which command will be used to deal with clipboards
CLIPBOARD_MODE=

# Specify what happens when pressing Enter on an item.
# Defaults to copy_password, can be changed to (auto_type all) or (auto_type password)
ENTER_CMD=copy_password

# Keyboard shortcuts
KB_SYNC="Alt+r"
KB_URLSEARCH="Alt+u"
KB_NAMESEARCH="Alt+n"
KB_FOLDERSELECT="Alt+c"
KB_TOTPCOPY="Alt+t"
KB_LOCK="Alt+L"
KB_TYPEALL="Alt+1"
KB_TYPEUSER="Alt+2"
KB_TYPEPASS="Alt+3"

# Item type classification
TYPE_LOGIN=1
TYPE_NOTE=2
TYPE_CARD=3
TYPE_IDENTITY=4

# Populated in parse_cli_arguments
ROFI_OPTIONS=()
DEDUP_MARK="(+)"

# Source helper functions
DIR="$(dirname "$(readlink -f "$0")")"
source "$DIR/lib-bwmenu"

ask_password() {
  mpw=$(printf '' | rofi -dmenu -p "Master Password" -password -lines 0) || exit $?
  echo "$mpw" | bw unlock 2>/dev/null | grep 'export' | sed -E 's/.*export BW_SESSION="(.*==)"$/\1/' || exit_error $? "Could not unlock vault"
}

get_session_key() {
  if [ $AUTO_LOCK -eq 0 ]; then
    keyctl purge user bw_session &>/dev/null
    BW_HASH=$(ask_password)
  else
    if ! key_id=$(keyctl request user bw_session 2>/dev/null); then
      session=$(ask_password)
      [[ -z "$session" ]] && exit_error 1 "Could not unlock vault"
      key_id=$(echo "$session" | keyctl padd user bw_session @u)
    fi
    
    if [ $AUTO_LOCK -gt 0 ]; then
      keyctl timeout "$key_id" $AUTO_LOCK
    fi
    BW_HASH=$(keyctl pipe "$key_id")
  fi
}

# source the hash file to gain access to the BitWarden CLI
# Pre fetch all the items
load_items() {
  if ! ITEMS=$(bw list items --session "$BW_HASH" 2>/dev/null); then
    exit_error $? "Could not load items"
  fi
}

exit_error() {
  local code="$1"
  local message="$2"

  rofi -e "$message"
  exit "$code"
}

# Show the Rofi menu with options
# Reads items from stdin
rofi_menu() {

  actions=(
    -kb-custom-1 $KB_SYNC
    -kb-custom-2 $KB_NAMESEARCH
    -kb-custom-3 $KB_URLSEARCH
    -kb-custom-4 $KB_FOLDERSELECT
    -kb-custom-8 $KB_TOTPCOPY
    -kb-custom-9 $KB_LOCK
  )

  msg="<b>$KB_SYNC</b>: sync | <b>$KB_URLSEARCH</b>: urls | <b>$KB_NAMESEARCH</b>: names | <b>$KB_FOLDERSELECT</b>: folders | <b>$KB_TOTPCOPY</b>: totp | <b>$KB_LOCK</b>: lock"

  [[ ! -z "$AUTOTYPE_MODE" ]] && {
    actions+=(
      -kb-custom-5 $KB_TYPEALL
      -kb-custom-6 $KB_TYPEUSER
      -kb-custom-7 $KB_TYPEPASS
    )
    msg+="
<b>$KB_TYPEALL</b>: Type all  | <b>$KB_TYPEUSER</b>: Type user | <b>$KB_TYPEPASS</b>: Type pass"
  }

  rofi -dmenu -p 'Name' \
    -i -no-custom \
    -mesg "$msg" \
    "${actions[@]}" \
    "${ROFI_OPTIONS[@]}"
}

# Show items in a rofi menu by name of the item
show_items() {
  if item=$(
    echo "$ITEMS" \
    | jq -r ".[] | select( has( \"login\" ) ) | \"\\(.name)\"" \
    | dedup_lines \
    | rofi_menu
  ); then
    item_array="$(array_from_name "$item")"
    "${ENTER_CMD[@]}" "$item_array"
  else
    rofi_exit_code=$?
    item_array="$(array_from_name "$item")"
    on_rofi_exit "$rofi_exit_code" "$item_array"
  fi
}

# Similar to show_items() but using the item's ID for deduplication
show_full_items() {
  if item=$(
    echo "$ITEMS" \
    | jq -r ".[] | select( has( \"login\" )) | \"\\(.id): name: \\(.name), username: \\(.login.username)\"" \
    | rofi_menu
  ); then
    item_id="$(echo "$item" | cut -d ':' -f 1)"
    item_array="$(array_from_id "$item_id")"
    "${ENTER_CMD[@]}" "$item_array"
  else
    rofi_exit_code=$?
    item_id="$(echo "$item" | cut -d ':' -f 1)"
    item_array="$(array_from_id "$item_id")"
    on_rofi_exit "$rofi_exit_code" "$item_array"
  fi
}

# Show items in a rofi menu by url of the item
# if url occurs in multiple items, show the menu again with those items only
show_urls() {
  if url=$(
    echo "$ITEMS" \
    | jq -r '.[] | select(has("login")) | .login | select(has("uris")).uris | .[].uri' \
    | rofi_menu
  ); then
    item_array="$(bw list items --url "$url" --session "$BW_HASH")"
    "${ENTER_CMD[@]}" "$item_array"
  else
    rofi_exit_code="$?"
    item_array="$(bw list items --url "$url" --session "$BW_HASH")"
    on_rofi_exit "$rofi_exit_code" "$item_array"
  fi
}

show_folders() {
  folders=$(bw list folders --session "$BW_HASH")
  if folder=$(echo "$folders" | jq -r '.[] | .name' | rofi_menu); then

    folder_id=$(echo "$folders" | jq -r ".[] | select(.name == \"$folder\").id")

    ITEMS=$(bw list items --folderid "$folder_id" --session "$BW_HASH")
    show_items
  else
    rofi_exit_code="$?"
    folder_id=$(echo "$folders" | jq -r ".[] | select(.name == \"$folder\").id")
    item_array=$(bw list items --folderid "$folder_id" --session "$BW_HASH")
    on_rofi_exit "$rofi_exit_code" "$item_array"
  fi
}

# re-sync the BitWarden items with the server
sync_bitwarden() {
  bw sync --session "$BW_HASH" &>/dev/null || exit_error 1 "Failed to sync bitwarden"

  load_items
  show_items
}

# Evaluate the rofi exit codes
on_rofi_exit() {
  case "$1" in
    10) sync_bitwarden;;
    11) load_items; show_items;;
    12) show_urls;;
    13) show_folders;;
    17) copy_totp "$2";;
    18) lock_vault;;
    14) auto_type all "$2";;
    15) auto_type username "$2";;
    16) auto_type password "$2";;
    *) exit "$1";;
  esac
}

# Auto type using xdotool/ydotool
# $1: what to type; all, username, password
# $2: item array
auto_type() {
  if not_unique "$2"; then
    ITEMS="$2"
    show_full_items
  else
    sleep 0.3
    case "$1" in
      all)
        type_word "$(echo "$2" | jq -r '.[0].login.username')"
        type_tab
        type_word "$(echo "$2" | jq -r '.[0].login.password')"
        ;;
      username)
        type_word "$(echo "$2" | jq -r '.[0].login.username')"
        ;;
      password)
        type_word "$(echo "$2" | jq -r '.[0].login.password')"
        ;;
    esac
  fi

}

# Set $AUTOTYPE_MODE to a command that will emulate keyboard input
select_autotype_command() {
  if [[ -z "$AUTOTYPE_MODE" ]]; then
    if [ "$XDG_SESSION_TYPE" = "wayland" ] && hash ydotool 2>/dev/null; then
      AUTOTYPE_MODE=(sudo ydotool)
    elif [ "$XDG_SESSION_TYPE" != "wayland" ] && hash xdotool 2>/dev/null; then
      AUTOTYPE_MODE=xdotool
    fi
  fi
}

type_word() {
  "${AUTOTYPE_MODE[@]}" type "$1"
}

type_tab() {
  "${AUTOTYPE_MODE[@]}" key Tab
}


# Set $CLIPBOARD_MODE to a command that will put stdin into the clipboard.
select_copy_command() {
  if [[ -z "$CLIPBOARD_MODE" ]]; then
    if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
      hash wl-copy 2>/dev/null && CLIPBOARD_MODE=wayland
    elif hash xclip 2>/dev/null; then
      CLIPBOARD_MODE=xclip
    elif hash xsel 2>/dev/null; then
      CLIPBOARD_MODE=xsel
    fi
    [ -z "$CLIPBOARD_MODE" ] && exit_error 1 "No clipboard command found. Please install either xclip, xsel, or wl-clipboard."
  fi
}

clipboard-set() {
  clipboard-${CLIPBOARD_MODE}-set
}

clipboard-get() {
  clipboard-${CLIPBOARD_MODE}-get
}

clipboard-clear() {
  clipboard-${CLIPBOARD_MODE}-clear
}

clipboard-xclip-set() {
    xclip -selection clipboard -r
}

clipboard-xclip-get() {
    xclip -selection clipboard -o
}

clipboard-xclip-clear() {
    echo -n "" | xclip -selection clipboard -r
}

clipboard-xsel-set() {
  xsel --clipboard --input
}

clipboard-xsel-get() {
  xsel --clipboard
}

clipboard-xsel-clear() {
  xsel --clipboard --delete
}

clipboard-wayland-set() {
  wl-copy
}

clipboard-wayland-get() {
  wl-paste
}

clipboard-wayland-clear() {
  wl-copy --clear
}

# Copy the password
# copy to clipboard and give the user feedback that the password is copied
# $1: json array of items
copy_password() {
  if not_unique "$1"; then
    ITEMS="$1"
    show_full_items
  else
    pass="$(echo "$1" | jq -r '.[0].login.password')"

    show_copy_notification "$(echo "$1" | jq -r '.[0]')"
    echo -n "$pass" | clipboard-set

    if [[ $CLEAR -gt 0 ]]; then
      sleep "$CLEAR"
      if [[ "$(clipboard-get)" == "$pass" ]]; then
        clipboard-clear
      fi
    fi
  fi
}

# Copy the TOTP
# $1: item array
copy_totp() {
  if not_unique "$1"; then
    ITEMS="$item_array"
    show_full_items
  else
    id=$(echo "$1" | jq -r ".[0].id")

    if ! totp=$(bw --session "$BW_HASH" get totp "$id"); then
      exit_error 1 "$totp"
    fi

    echo -n "$totp" | clipboard-set
    notify-send "TOTP Copied"
  fi
}

# Lock the vault by purging the key used to store the session hash
lock_vault() {
  keyctl purge user bw_session &>/dev/null
}

# Show notification about the password being copied.
# $1: json item
show_copy_notification() {
  local title
  local body=""
  local extra_options=()

  title="<b>$(echo "$1" | jq -r '.name')</b> copied"

  if [[ $SHOW_PASSWORD == "yes" ]]; then
    pass=$(echo "$1" | jq -r '.login.password')
    body="${pass:0:4}****"
  fi

  if [[ $CLEAR -gt 0 ]]; then
    body="$body<br>Will be cleared in ${CLEAR} seconds."
    # Keep notification visible while the clipboard contents are active.
    extra_options+=("-t" "$((CLEAR * 1000))")
  fi
  # not sure if icon will be present everywhere, /usr/share/icons is default icon location
  notify-send "$title" "$body" "${extra_options[@]}" -i /usr/share/icons/hicolor/64x64/apps/bitwarden.png
}

parse_cli_arguments() {
  # Use GNU getopt to parse command line arguments
  if ! ARGUMENTS=$(getopt -o c:C --long auto-lock:,clear:,no-clear,show-password,state-path:,help,version -- "$@"); then
    exit_error 1 "Failed to parse command-line arguments"
  fi
  eval set -- "$ARGUMENTS"

  while true; do
    case "$1" in
      --help )
        cat <<-USAGE
$NAME $VERSION

Usage:
  $NAME [options] -- [rofi options]

Options:
  --help
      Show this help text and exit.

  --version
      Show version information and exit.

  --auto-lock <SECONDS>
      Automatically lock the Vault <SECONDS> seconds after last unlock.
      Use 0 to lock immediatly.
      Use -1 to disable.
      Default: 900 (15 minutes)

  -c <SECONDS>, --clear <SECONDS>, --clear=<SECONDS>
      Clear password from clipboard after this many seconds.
      Defaults: ${DEFAULT_CLEAR} seconds.

  -C, --no-clear
      Don't automatically clear the password from the clipboard. This disables
      the default --clear option.

  --show-password
      Show the first 4 characters of the copied password in the notification.

Quick Actions:
  When hovering over an item in the rofi menu, you can make use of Quick Actions.

  $KB_SYNC  Resync your vault

  $KB_URLSEARCH  Search through urls
  $KB_NAMESEARCH  Search through names
  $KB_FOLDERSELECT  Search through folders

  $KB_TOTPCOPY  Copy the TOTP
  $KB_TYPEALL  Autotype the username and password [needs xdotool or ydotool]
  $KB_TYPEUSER  Autotype the username [needs xdotool or ydotool]
  $KB_TYPEPASS  Autotype the password [needs xdotool or ydotool]
  
  $KB_LOCK  Lock your vault

Examples:
  # Default options work well
  $NAME

  # Immediatly lock the Vault after use
  $NAME --auto-lock 0

  # Never lock the Vault
  $NAME --auto-lock -1

  # Place rofi on top of screen, like a Quake console
  $NAME -- -location 2
USAGE
        shift
        exit 0
        ;;
      --version )
        echo "$NAME $VERSION"
        shift
        exit 0
        ;;
      --auto-lock )
        AUTO_LOCK=$2
        shift 2
        ;;
      -c | --clear )
        CLEAR="$2"
        shift 2
        ;;
      -C | --no-clear )
        CLEAR=0
        shift
        ;;
      --show-password )
        SHOW_PASSWORD=yes
        shift
        ;;
      -- )
        shift
        ROFI_OPTIONS=("$@")
        break
        ;;
      * )
        exit_error 1 "Unknown option $1"
    esac
  done
}

parse_cli_arguments "$@"

get_session_key
select_autotype_command
select_copy_command
load_items
show_items
