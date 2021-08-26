#!/bin/bash
#
# set.bash
#
# v0.0.2 - 2019-09-04 - nelbren@nelbren.com
# v0.0.3 - 2020-07-14 - nelbren@nelbren.com
# v0.0.4 - 2021-08-26 - nelbren@nelbren.com
#

base=/usr/local/npres
alias si="$base/bin/system/si.bash"
alias p3="$base/bin/system/p3.bash"
alias m3="$base/bin/system/m3.bash"


[ "$TERM" != "dumb" -a -z "$SUDO_COMMAND" ] && si
