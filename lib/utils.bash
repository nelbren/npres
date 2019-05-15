#!/bin/bash
#
# utils.bash
#
# v0.0.1 - 2018-02-07 - nelbren@nelbren.com
# v0.0.2 - 2018-02-08 - nelbren@nelbren.com
# v0.0.3 - 2018-04-09 - nelbren@nelbren.com
# v0.0.4 - 2018-05-23 - nelbren@nelbren.com
# v0.0.5 - 2018-05-23 - nelbren@nelbren.com - replace bc -> perl
#

get_hostname() {
  host=$(hostname --fqdn)
  if [ "$host" == "localhost.localdomain" ]; then
    host0=$(hostname)
    host1=$(grep domain /etc/resolv.conf | cut -d" " -f2)
    host=$host0.$host1
  fi
  echo $host
}

convert_from_seconds_to() {
  measure[0]='d'; measure[1]='h'; measure[2]='m'; measure[3]='s'
  value=$1

  # 3600 * 24hours = 86400 seconds contains 1 day
  contains=86400
  #days=$(echo -e "scale=0\n${value}/$contains" | bc)
  days=$(echo print "${value}/$contains" | perl)
  if [ "$days" == "0" ]; then
    output=""
    days_seconds=0
  else
    output="${days}${measure[0]}"
    #days_seconds=$(echo -e "scale=0\n${days}*$contains" | bc)
    days_seconds=$(echo print "${days}*$contains" | perl)
  fi

  # 60seconds * 60minutes = 3600 seconds contains 1 hora
  contains=3600
  #hours=$(echo -e "scale=0\n(${value}-$days_seconds)/$contains" | bc)
  hours=$(echo print "(${value}-$days_seconds)/$contains" | perl)
  if [ "$hours" == "0" ]; then
    hours_seconds=0
  else
    if [ -n "$output" ]; then
      output="${output}${hours}${measure[1]}"
    else
      output="${hours}${measure[1]}"
    fi
    #hours_seconds=$(echo -e "scale=0\n${hours}*$contains" | bc)
    hours_seconds=$(echo print "${hours}*$contains" | perl)
  fi

  # 60seconds * 1minuto = 60 seconds contains 1 minuto
  contains=60
  #minutes=$(echo -e "scale=0\n(${value}-$days_seconds-$hours_seconds)/$contains" | bc)
  minutes=$(echo print "(${value}-$days_seconds-$hours_seconds)/$contains" | perl)
  if [ "$minutes" == "0" ]; then
    minutes_seconds=0
  else
    if [ -n "$output" ]; then
      output="${output}$minutes${measure[2]}"
    else
      output="${minutes}${measure[2]}"
    fi
    #minutes_seconds=$(echo -e "scale=0\n${minutes}*$contains" | bc)
    minutes_seconds=$(echo print "${minutes}*$contains" | perl)
  fi

  #seconds=$(echo -e "scale=0\n${value}-$days_seconds-$hours_seconds-$minutes_seconds" | bc)
  seconds=$(echo print "${value}-$days_seconds-$hours_seconds-$minutes_seconds" | perl)
  if [ "$seconds" == "0" ]; then
    seconds_seconds=0
    output="${seconds}${measure[3]}"
  else
    if [ -n "$output" ]; then
      output="${output}${seconds}${measure[3]}"
    else
      output="${seconds}${measure[3]}"
    fi
  fi

  echo $output
}

diff_seconds() {
  past_time=$1
  current_time=$2
  echo $(( $(date --date="$current_time" +%s) - $(date --date="$past_time" +%s) ))
}
