#!/bin/bash
#
# set.bash
#
# v0.0.2 - 2019-09-04 - nelbren@nelbren.com
#

base=/usr/local/npres
alias si="$base/bin/system/si.bash"

[ "$TERM" != "dumb" -a -z "$SUDO_COMMAND" ] && si
