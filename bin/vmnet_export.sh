#!/bin/sh

SHARED_FOLDER="${1:-/Users}"

VMNET="/Library/Preferences/SystemConfiguration/com.apple.vmnet"
if [ ! -f "${VMNET}.plist" ]; then
  exit
fi

IP_ADDR=$(defaults read ${VMNET} Shared_Net_Address)
NET_MASK=$(defaults read ${VMNET} Shared_Net_Mask)

function ip2num() {
  local IFS=.
  local ip=($1)
  printf "%s\n" $(( (${ip[0]} << 24) | (${ip[1]} << 16) | (${ip[2]} << 8) | ${ip[3]} ))
}

function num2ip() {
  local n=$1
  printf "%d.%d.%d.%d\n" \
    $(( $n >> 24 )) $(( ($n >> 16) & 0xFF )) $(( ($n >> 8) & 0xFF )) $(( $n & 0xFF ))
}

NET_NUM=$(( $(ip2num ${IP_ADDR}) & $(ip2num ${NET_MASK}) ))
NET_ADDR=$(num2ip ${NET_NUM})

echo "\"${SHARED_FOLDER}\" -network ${NET_ADDR} -mask ${NET_MASK} -alldirs -mapall=$(id -u $SUDO_USER):$(id -g $SUDO_USER)"
