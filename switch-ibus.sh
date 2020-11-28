#!/bin/bash
[ $(ibus engine) = 'xkb:us::eng' ] && ibus engine xkb:vn::vie || ibus engine xkb:us::eng