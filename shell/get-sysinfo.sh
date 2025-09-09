#!/bin/sh

category=$1

handle_wifi() {
   local state=$(iwctl station wlp4s0 show | awk '/State/ {print $2}')
   if [ "$state" = "connected" ] ; then
     echo "󰖩 "
   else
     echo "󱚵 "
   fi
}

handle_brightness() {
  local light=$(brightnessctl get)
  local max=$( brightnessctl max )
  printf "%.0f\n" $(((light*100)/max))
}

handle_mem() {
  local used=$(free | awk '/Mem:/ {print $3}')
  local total=$(free | awk '/Mem:/ {print $2}')
  printf "%d\n" $((used * 100 / total))
}

handle_root_disk() {
  echo "$(df -h  / | grep -Eo "[0-9]{1,}%" | cut -d '%' -f 1)"
}

handle_cpu() {
  read cpu user nice system idle rest < /proc/stat
  local total=$((user + nice + system + idle))
  local busy=$((user + nice + system))
  echo $((100 * busy / total))
}

handle_volume() {
  local out=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
  local vol=$(echo "$out" | awk '{print $2*100}' | cut -d'.' -f1)
  if echo "$out" | grep -q MUTED; then
    echo " $vol%"
  else
    echo " $vol%"
  fi
}

case "$category" in
  "--wifi")
    handle_wifi 
	exit 0 ;;
  "--brightness")
    handle_brightness 
	exit 0 ;;
  "--mem")
    handle_mem 
	exit 0 ;;
  "--root-disk")
    handle_root_disk 
	exit 0 ;;
  "--cpu")
    handle_cpu 
	exit 0 ;;
  "--volume")
    handle_volume 
   	exit 0 ;;
  *)
    exit 0 ;;
esac
    
