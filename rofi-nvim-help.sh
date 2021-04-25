awk '/^[a-z]/ && last {print $0,"\t",last} {last=""} /^" ---/{last=$0}' ~/.config/nvim/keymaps.vim | column -t -s $'\t' | rofi -dmenu -p "List of binding and command"
