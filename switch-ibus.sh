#!/bin/bash
[ $(ibus engine) = 'xkb:us::eng' ] && ibus engine Bamboo || ibus engine xkb:us::eng
polybar-msg hook ipc-vie-eng 1
exit 0