#!/bin/bash

base=/usr/local/npres
alias si="$base/bin/system/si.bash"

[ "$TERM" == "dumb" ] || si
