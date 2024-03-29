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
# v0.0.9 - 2019-04-02 - nelbren@nelbren.com
# v0.1.0 - 2019-05-15 - nelbren@nelbren.com - replace bc -> perl
# v0.1.1 - 2019-07-16 - nelbren@nelbren.com - procs 250->350,300->400
# v0.1.2 - 2019-10-27 - nelbren@nelbren.com - *100 -> 100*
# v0.1.3 - 2019-11-28 - nelbren@nelbren.com - fix this alien -> ç
# v0.1.4 - 2020-01-29 - nelbren@nelbren.com - check_net fixes
# v0.1.5 - 2020-10-08 - nelbren@nelbren.com - procs 350->450,400->500
# v0.1.6 - 2020-12-02 - nelbren@nelbren.com - lxc /proc/stat show global procs_running
# v0.1.7 - 2023-04-22 - nelbren@nelbren.com - check_fs 90 -> 95, 95 -> 99
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
  #echo "scale=1;i=$num/1;scale=0;j=$num/1;j +(i-j>=.5)" | bc
  printf "%.*f\n" 0 $num
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
  l=${#uptime}; l=$((l-1)); f="d"
  [ "${uptime:$l:1}" == "s" ] && f=""
  raw="U${uptime}${f}"

  cmf=/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq
  if [ -r $cmf ]; then
    hz=$(cat $cmf)
    #mhz=$(echo $hz/1000 | bc)
    mhz=$(echo print $hz/1000 | perl)
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

  #pmem=$(echo -e "scale=2\n($memused/$memtotal)*100" | bc)
  pmem=$(echo print "100*($memused/$memtotal)" | perl)
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

    #pswap=$(echo -e "scale=2\n($swapused/$swaptotal)*100" | bc)
    pswap=$(echo print "($swapused/$swaptotal)*100" | perl)
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

  #rprocs=$(grep procs_running /proc/stat | cut -d" " -f2)
  rprocs=$(cat /proc/[0-9]*/status 2>/dev/null | grep running | wc -l)
  raw="$raw/R$rprocs"

  data_in=$(df -h / | tail -1)
  regex="([0-9]+%)\s*\/$"
  pfs=$(regex_get "$regex" "$data_in")
  raw="$raw F/=$pfs"

  data_in=$(grep "00000000" /proc/net/route | head -1)
  regex="^(\w+)\s*"
  interface=$(regex_get "$regex" "$data_in")

  prerx=''
  rounds=1
  while [ "$rounds" -ge "0" ]; do
    if [ -z "$prerx" ]; then
      prerx=$rx
      pretx=$tx
    fi

    data_in=$(grep $interface /proc/net/dev)

#Inter-|   Receive                                                |  Transmit
# face |bytes    packets errs drop fifo frame compressed multicast|bytes    packets errs drop fifo colls carrier compressed
#   eth0: 4726508496 55445305    0 298036    0     0          0         0 13880888204 5307580    0    1    0     0       0          0
#     1        2        3        4   5       6     7          8         9 10

    rx=$(echo $data_in | cut -d" " -f2)

    tx=$(echo $data_in | cut -d" " -f10)
    #echo $data_in
    #echo $rx $tx
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
  [ $subvalue1 -gt 450 ] && state=$STATE_WARNING
  [ $subvalue1 -gt 500 ] && state=$STATE_CRITICAL
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
  [ $nsubvalue -gt 95 ] && state=$STATE_WARNING
  [ $nsubvalue -gt 99 ] && state=$STATE_CRITICAL
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
    #Mib) bytes=$(echo -e "($numbers/8)*$mult*$mult\n" | bc);;
    # https://www.gbmb.org/mbit-to-bytes 
    Mib) bytes=$(echo print "$numbers*125000" | perl);;
      B) bytes=$numbers;;
    #KiB) bytes=$(echo -e "$numbers*$mult\n" | bc);;
    KiB) bytes=$(echo print "$numbers*$mult" | perl);;
    #MiB) bytes=$(echo -e "$numbers*$mult*$mult\n" | bc);;
    MiB) bytes=$(echo print "$numbers*$mult*$mult" | perl);;
    #GiB) bytes=$(echo -e "$numbers*$mult*$mult*$mult\n" | bc);;
    GiB) bytes=$(echo print "$numbers*$mult*$mult*$mult" | perl);;
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
    speed=$(/sbin/iw dev $interface link | grep bitrate | cut -d":" -f2)
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
  #bytes_usage=$(echo -e "$bytes1+$bytes2\n" | bc)
  bytes_usage=$(echo print "$bytes1+$bytes2" | perl)
  #p=$(echo -e "scale=2\n$bytes_usage/$bytes_interface\n" | bc)
  p=$(echo print "$bytes_usage/$bytes_interface" | perl)
  #p=$(echo -e "$p*100\n" | bc)
  p=$(echo print "$p*100" | perl)
  p=$(approximation $p)
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
  if [ ! -x /usr/bin/perl ]; then
    echo -e "${iy}Please install perl$S\n${cOK}apt -y install perl$S"
    exit 1
  fi
}

datehour_when=$(date +'%Y-%m-%d %H:%M:%S')

utils=/usr/local/npres/lib/utils.bash
[ -x $utils ] || exit 1
. $utils

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
