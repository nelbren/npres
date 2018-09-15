#!/bin/bash
#
# si.bash
#
# v0.0.1 - 2018-04-22 - nelbren@nelbren.com
# v0.0.2 - 2018-05-23 - nelbren@nelbren.com
# v0.0.3 - 2018-05-24 - nelbren@nelbren.com
# v0.0.4 - 2018-05-25 - nelbren@nelbren.com
# v0.0.5 - 2018-06-04 - nelbren@nelbren.com
# v0.0.6 - 2018-07-18 - nelbren@nelbren.com
# v0.0.7 - 2018-09-06 - nelbren@nelbren.com
# v0.0.8 - 2018-10-15 - nelbren@nelbren.com
#

use() {
  echo "Usage: "
  echo "       $myself [OPTION]"
  echo ""
  echo "Extracts the information from the system or the files of the process, "
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
  before=$4
  hight=$5
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
    else
      color2=$Ib
    fi
  else
    color2=""
  fi
  line2=$(echo -en $S)$(echo -en $color2)${msg1}$(echo -en $color)${msg2}$(echo -en $S)
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

regex_get() {
  regex=$1
  data_in=$2
  data_out=""
  [[ $data_in =~ $regex ]] && data_out=${BASH_REMATCH[1]}
  echo $data_out
}

approximation() {
  num=$1
  echo "scale=1;i=$num/1;scale=0;j=$num/1;j +(i-j>=.5)" | bc
}

cpu_get() {
  # http://colby.id.au/calculating-cpu-usage-from-proc-stat/
  # by Paul Colby (http://colby.id.au), no rights reserved ;)
  PREV_TOTAL=0
  PREV_IDLE=0

  rounds=2

  while [ "$rounds" -gt "0" ]; do

    CPU=(`cat /proc/stat | grep '^cpu '`) # Get the total CPU statistics.
    unset CPU[0]                          # Discard the "cpu" prefix.
    IDLE=${CPU[4]}                        # Get the idle CPU time.

    # Calculate the total CPU time.
    TOTAL=0
    for VALUE in "${CPU[@]:0:4}"; do
      let "TOTAL=$TOTAL+$VALUE"
    done

    # Calculate the CPU usage since we last checked.
    let "DIFF_IDLE=$IDLE-$PREV_IDLE"
    let "DIFF_TOTAL=$TOTAL-$PREV_TOTAL"
    let "DIFF_USAGE=(1000*($DIFF_TOTAL-$DIFF_IDLE)/$DIFF_TOTAL+5)/10"

    # Remember the total and idle CPU times for the next check.
    PREV_TOTAL="$TOTAL"
    PREV_IDLE="$IDLE"

    # Wait before checking again.
    sleep 0.5
    let "rounds=$rounds-1"
  done
  echo "$DIFF_USAGE%"
}

raw_get() {
  uptime=$(awk '{printf("%dd%dh%dm%ds\n",($1/60/60/24),($1/60/60%24),($1/60%60),($1%60))}' /proc/uptime)
  uptime=$(echo $uptime | sed "s/^0d//")
  uptime=$(echo $uptime)
  uptime=$(echo $uptime | cut -d"d" -f1)
  raw="U${uptime}d"

  cmf=/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq
  if [ -r $cmf ]; then
    hz=$(cat $cmf)
    mhz=$(echo $hz/1000 | bc)
  else
    data_in=$(grep -E "^cpu MHz" /proc/cpuinfo | head -1)
    regex="^cpu MHz\s*:\s*([0-9]+.[0-9]+)"
    mhz=$(regex_get "$regex" "$data_in")
    mhz=$(approximation $mhz)
  fi

  raw="$raw M$mhz"

  data_in=$(free | grep -E "^Mem:")
  regex="^Mem:\s*([0-9]+)"
  memtotal=$(regex_get "$regex" "$data_in")
  #echo $memtotal

  regex="^Mem:\s*[0-9]+\s*([0-9]+)"
  memused=$(regex_get "$regex" "$data_in")
  #echo $memused

  data_in=$(free | grep -E "^-\/\+ buffers\/cache:")
  regex="^-\/\+ buffers\/cache:\s*([0-9]+)"
  if [ -n "$data_in" ]; then
    memused=$(regex_get "$regex" "$data_in")
    #echo $memused
  fi

  pmem=$(echo -e "scale=2\n($memused/$memtotal)*100" | bc)
  pmem=$(approximation $pmem)

  raw="$raw R$pmem%"

  data_in=$(free | grep -E "^Swap:")
  regex="^Swap:\s*([0-9]+)"
  swaptotal=$(regex_get "$regex" "$data_in")

  if [ "$swaptotal" == "0" ]; then
    pswap=-1
  else
    regex="^Swap:\s*[0-9]+\s*([0-9]+)"
    swapused=$(regex_get "$regex" "$data_in")

    pswap=$(echo -e "scale=2\n($swapused/$swaptotal)*100" | bc)
    pswap=$(approximation $pswap)
  fi
  if [ "$pswap" != "-1" ]; then
    raw="$raw S$pswap%"
  fi
  
  cpus=$(cat /proc/cpuinfo | grep processor | wc -l)
  pcpu=$(cpu_get)
  raw="$raw C$cpus=$pcpu"

  procs=$(ls -ld /proc/[0-9]* 2>/dev/null | wc -l)
  raw="$raw P$procs"

  rprocs=$(grep procs_running /proc/stat | cut -d" " -f2)
  raw="$raw/R$rprocs"

  data_in=$(df -h / | tail -1)
  regex="([0-9]+%)\s*\/$"
  pfs=$(regex_get "$regex" "$data_in")
  raw="$raw F/=$pfs"

  data_in=$(grep "00000000" /proc/net/route | head -1)
  regex="^(\w+)\s*"
  interface=$(regex_get "$regex" "$data_in")

  prerx=''
  rounds=2
  while [ "$rounds" -ge "0" ]; do
    if [ -z "$prerx" ]; then
      prerx=$rx
      pretx=$tx
    fi

    data_in=$(grep $interface /proc/net/dev)
    rx=$(echo $data_in | cut -d" " -f2)

    tx=$(echo $data_in | cut -d" " -f10)
    rounds=$((rounds-1))
  done

  diffrx=$(($rx-$prerx))
  difftx=$(($tx-$pretx))

  raw="$raw NU${difftx}B/D${diffrx}B"

  if [ -r /etc/debian_version ]; then
    DV=$(cat /etc/debian_version)
  else
    DV=""
  fi

  raw="D$(date +'%Y%m%d%H%M%S') $raw V$DV"
}

check_dt() {
  dt=$value
  dtn=$(date +'%Y%m%d%H%M%S')
  diff=$((dtn-dt))
  [ $diff -gt 1 ] && state=$STATE_CRITICAL
  color_msg $state ${label} $dt
}

check_dv() {
  dv=$value
  dv0=$(echo $dv | cut -d"." -f1)
  #[ $dv0 -lt 9 ] && state=$STATE_WARNING
  #[ $dv0 -lt 8 ] && state=$STATE_CRITICAL
  color_msg $state $label $dv
}

check_info() {
  color_msg $STATE_INFO ${label} $value
}

check_ram() {
  nvalue=$(echo $value | cut -d"%" -f1)
  color_msg $STATE_INFO ${label} "" 0 1
  [ $nvalue -gt 80 ] && state=$STATE_WARNING
  [ $nvalue -gt 90 ] && state=$STATE_CRITICAL
  color_msg $state "" $value
  nag_ram=$nvalue
}

check_swap() {
  nvalue=$(echo $value | cut -d"%" -f1)
  color_msg $STATE_INFO ${label} "" 0 1
  if [ "$nvalue" != "Noswap" ]; then
    [ $nvalue -gt 60 ] && state=$STATE_WARNING
    [ $nvalue -gt 80 ] && state=$STATE_CRITICAL
  fi
  color_msg $state "" $value
}

check_cpu() {
  subvalue1=$(echo $value | cut -d"=" -f1)
  subvalue2=$(echo $value | cut -d"=" -f2)  
  color_msg $STATE_INFO ${label} ${subvalue1}= 0 1
  nvalue=$(echo $subvalue2 | cut -d"%" -f1)
  [ $nvalue -gt 50 ] && state=$STATE_WARNING
  [ $nvalue -gt 75 ] && state=$STATE_CRITICAL
  color_msg $state "" $subvalue2
  nag_cpu=$nvalue
}

check_procs() {
  subvalue1=$(echo $value | cut -d"/" -f1)
  subvalue2=$(echo $value | cut -d"/" -f2)
  subsubvalue1=${subvalue2:0:1}
  subsubvalue2=${subvalue2:1}
  color_msg $STATE_INFO ${label} "" 0 1
  [ $subvalue1 -gt 250 ] && state=$STATE_WARNING
  [ $subvalue1 -gt 300 ] && state=$STATE_CRITICAL
  color_msg $state "" ${subvalue1}
  color_msg $STATE_INFO "" \/${subsubvalue1}=
  state=$STATE_OK
  [ $subsubvalue2 -gt 5 ] && state=$STATE_WARNING
  [ $subsubvalue2 -gt 10 ] && state=$STATE_CRITICAL
  color_msg $state "" $subsubvalue2 
}

check_fs() {
  subvalue1=$(echo $value | cut -d"=" -f1)
  subvalue2=$(echo $value | cut -d"=" -f2)
  nsubvalue=$(echo $subvalue2 | cut -d"%" -f1 | cut -d"." -f1)
  color_msg $STATE_INFO ${label} ${subvalue1}= 0 1
  [ $nsubvalue -gt 90 ] && state=$STATE_WARNING
  [ $nsubvalue -gt 95 ] && state=$STATE_CRITICAL
  color_msg $state "" $subvalue2
  nag_fs=$nsubvalue
}

convert_to_bytes() {
  human=$1
  numbers=$(echo "$human" | sed 's/\([0-9.]*\).*/\1/')
  measure=$(echo "$human" | sed 's/[0-9.]*\(.*\)/\1/')
  mult=1024
  # Mib tested on:
  # http://www.matisse.net/bitcalc/?input_amount=1000&input_units=megabits
  case $measure in
    Mib) bytes=$(echo -e "($numbers/8)*$mult*$mult\n" | bc);;
      B) bytes=$numbers;;
    KiB) bytes=$(echo -e "$numbers*$mult\n" | bc);;
    MiB) bytes=$(echo -e "$numbers*$mult*$mult\n" | bc);;
    GiB) bytes=$(echo -e "$numbers*$mult*$mult*$mult\n" | bc);;
  esac
  echo $bytes
}

check_net() {
  #UP=97B/DN=149B
  subvalue1=$(echo $value | cut -d"/" -f1)
  subvalue2=$(echo $value | cut -d"/" -f2)
  subsubvalue1=${subvalue1:1}
  subsubvalue2=${subvalue2:1}
  ethtool=/sbin/ethtool
  speed=""
  if [ -x /sbin/iw ]; then
    speed=$(iw dev $interface link | grep bitrate | cut -d":" -f2)ç
    speed=$(echo $speed | cut -d" " -f1)
    speed=$(echo $speed | cut -d"." -f1)
  fi
  if [ -z "$speed" ]; then
    if [ -x $ethtool ]; then
      speed=$($ethtool $interface 2>/dev/null | grep Speed | sed 's/.*: \([0-9]*\)M.*/\1/')
    fi
  fi
  if  [ -z "$speed" ] ; then
    speed=1000 #default speed of interface
  fi
  bytes_interface=$(convert_to_bytes ${speed}Mib) 
  bytes1=$(convert_to_bytes ${subsubvalue1})
  bytes2=$(convert_to_bytes ${subsubvalue2})
  bytes_usage=$(echo -e "$bytes1+$bytes2\n" | bc)
  p=$(echo -e "scale=2\n$bytes_usage/$bytes_interface\n" | bc)
  p=$(echo -e "$p*100\n" | bc)
  nvalue=$(echo $p | cut -d"." -f1)
  #echo $bytes_usage $bytes_interface $p $nvalue
  color_msg $STATE_INFO ${label} $value=
  [ $nvalue -gt 75 ] && state=$STATE_WARNING
  [ $nvalue -gt 80 ] && state=$STATE_CRITICAL
  #bytesX=$(echo -e "$bytes_usage/1240\n" | bc)
  #color_msg $state "" "$p%($bytes1 + $bytes2 = $bytes_usage ~ $bytesX K)"
  color_msg $state "" $p%
}

raw_system() {
  line=" ${line}"
  short=$(echo $host | cut -d"." -f1)
  color_msg $bstate "" "[SYSTEM:${short}]" 1
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
  nagios="$nagios$sep1$sep2$label$value$sep2"
  [ -z "$sep1" ] && sep1=" "
}

raw_check() {
  nagios=""
  sep1=""
  echo $raw | tr "[ ]" "[\n]" | \
  while read linea; do
    label=${linea:0:1}
    value=${linea:1}
    state=$STATE_OK
    case $label in
      D) check_dt;;
      V) check_dv;;
    U|M) check_info;;
      N) check_net;;
      R) check_ram;;
      S) check_swap;;
      C) check_cpu;;
      P) check_procs;;
      F) check_fs;;
      *) echo $label
         echo -e "\t$value";;
    esac
    nagios_line
    line="${line} "
  done
  time_usage
  bstate_to_status_type
}

pkg_check() {
  if [ ! -x /usr/bin/bc ]; then
    echo -e "${iy}Please install bc$S\n${cOK}apt -y install bc$S"
    exit 1
  fi
}

utils=/usr/local/npres/lib/utils.bash
[ -x $utils ] || exit 1
. $utils

stc=/usr/local/npres/lib/super-tiny-colors.bash
[ -x $stc ] || exit 1
. $stc

set +m
shopt -s lastpipe

myself=$(basename $0)
datehour_when=$(date +'%Y-%m-%d %H:%M:%S')

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
STATE_DEPENDENT=4
STATE_INFO=5

bstate=$STATE_OK
base=/usr/local/npres

params $@

[ "$HELP" == "1" ] && use

pkg_check
raw_get
raw_check

if [ "$NAGIOS" == "1" ]; then
  echo "$status_type - $nagios | ram=$nag_ram cpu=$nag_cpu fs=$nag_fs"
else
  echo -e "$line"
fi

exit $bstate
