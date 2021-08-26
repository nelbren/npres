#!/bin/bash
#
# m3.bash
#
# v0.0.1 - 2021-08-26 - nelbren@nelbren.com
#

use() {
  echo "Usage: "
  echo "       $myself [OPTION]"
  echo ""
  echo "Extract the three processes that use the highest percentage of memory,"
  echo "according to the thresholds it assigns the color, and shows everything"
  echo " in a single line in less than 80 characters. More info at nelbren.com"
  echo ""
  echo -e "Where: "
  echo -e "       -i|--invert\tShow info in invert colors."
  echo -e "       -n|--nagios\tShow info in plain text and stats for nagios"
  echo -e "       -h|--help\tShow this information."
  exit 0
}

params() {
  for i in "$@"; do
    case $i in
      --invert|-i) INVERT=1; shift;;
      --nagios|-n) NAGIOS=1; shift;;
      --help|-h) HELP=1; shift;;
      *) # unknown option
      ;;
    esac
  done

  [ -z "$INVERT" ] && INVERT=0
  [ -z "$NAGIOS" ] && NAGIOS=0
  [ -z "$HELP" ] && HELP=0
}


color_msg() {
  pstate=$1
  msg1=$2
  msg2=$3
  msg3=$4
  before=$5
  hight=$6
  if [ "$INVERT" == "0" ]; then
    case $pstate in
      $STATE_OK)       color="$cOK";;
      $STATE_WARNING)  color="$cWA";;
      $STATE_CRITICAL) color="$cCR";;
      $STATE_UNKNOWN)  color="$cUN";;
      $STATE_INFO)     color="$cIN";;
    esac
  else
    case $pstate in
      $STATE_OK)       color="$COK";;
      $STATE_WARNING)  color="$CWA";;
      $STATE_CRITICAL) color="$CCR";;
      $STATE_UNKNOWN)  color="$CUN";;
      $STATE_INFO)     color="$CIN2";;
    esac
  fi
  if [ "$hight" == "1" ]; then
    if [ "$INVERT" == "0" ]; then
      color2=$nB
      color3=$nW
    else
      color2=$Ib
      color3=$Iw
    fi
  else
    color2=""
    color3=""
  fi
  line2=$(echo -en $S)$(echo -en $color)${msg3}$(echo -en $color2)${msg1}@$(echo -en $color3)${msg2}$(echo -en $S)
  if [ "$before" == "1" ]; then
    line=${line2}${line}
  else
    line=${line}${line2}
  fi
  if [ "$pstate" -gt "$bstate" -a "$bstate" != "$STATE_CRITICAL" -a "$pstate" != "$STATE_INFO" ]; then
    bstate=$pstate
  fi
}


bstate_to_status_type() {
  case $bstate in
   $STATE_OK) status_type="OK";;
   $STATE_WARNING) status_type="WARNING";;
   $STATE_CRITICAL) status_type="CRITICAL";;
  esac
}

time_usage() {
  datehour_now=$(date +'%Y-%m-%d %H:%M:%S')
  diff=$(diff_seconds "$datehour_when" "$datehour_now")
  diff_human=$(convert_from_seconds_to $diff)
  color_msg $STATE_INFO T "$diff_human"
}

nagios_line() {
  [ "$NAGIOS" == "0" ] && return
  if [ "$state" != "$STATE_OK" ]; then
    sep2='*'
  else
    sep2=''
  fi
  nagios="$nagios$sep1$sep2$mem%$USER@$cmd$sep2"
  [ -z "$sep1" ] && sep1=" "
}

stc=/usr/local/npres/lib/super-tiny-colors.bash
[ -x $stc ] || exit 1
. $stc

set +m
shopt -s lastpipe

myself=$(basename $0)

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
STATE_DEPENDENT=4
STATE_INFO=5

bstate=$STATE_OK
#INVERT=1

params $@

[ "$HELP" == "1" ] && use

line=""
nagios=""
sep1=""
n=0
declare -a procs

ps aux --no-headers | sort -nrk 4,4 | head -n 3 | \
while read USER PID CPU MEM VSZ RSS TTY STAT START TIME COMMAND; do
   #echo $CPU $COMMAND $USER
  mem=$(printf "%03.2f" "$MEM")
  cmd=$(echo $COMMAND | cut -d" " -f1)
  cmd=$(basename $cmd)
  [ -n "$line" ] && line="$line "

  state=$STATE_OK

  (( $(echo "$mem > 30" | bc -l ) )) && state=$STATE_WARNING
  (( $(echo "$mem > 60" | bc -l ) )) && state=$STATE_CRITICAL
 
  nagios_line
  color_msg $state "$USER" "$cmd" "$mem%" 0 1
  procs[$n]=$mem
  n=$((n+1))
done

bstate_to_status_type

if [ "$NAGIOS" == "1" ]; then
  echo "$status_type - $nagios | proc1=${procs[0]} proc2=${procs[1]} proc3=${procs[2]}"
else
  echo -e "$line"
fi

exit $bstate
