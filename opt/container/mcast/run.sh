#!/bin/bash -e

IFNAME="eth0"

IFS=',' ; read -ra FEED <<< "${VLAN}"
MTU="$(ip link show "${IFNAME}" | awk '{print $5}')"

if [[ -n "${MAC}" ]]; then
  ip link set "${IFNAME}" down
  ip link set "${IFNAME}" address "${MAC}"
  ip link set "${IFNAME}" up
fi

ARG=""

for VLAN in "${FEED[@]}"; do
  if [[ ${VLAN} -gt 0 && ${VLAN} -lt 4096 ]]; then
    ARG="${ARG} ${IFNAME}.${VLAN}"

    if [[ ! -d "/sys/devices/virtual/net/${IFNAME}.${VLAN}" ]]; then
      ip link add link "${IFNAME}" name "${IFNAME}.${VLAN}" mtu "${MTU}" type "vlan" id "${VLAN}"
    fi

    ip link set "${IFNAME}.${VLAN}" up

    if [[ -f "/run/udhcpc.${IFNAME}.${VLAN}.pid" ]]; then
      kill "$(cat "/run/udhcpc.${IFNAME}.${VLAN}.pid")" || true
      rm -f "/run/udhcpc.${IFNAME}.${VLAN}.pid"
    fi

    udhcpc -b -i "${IFNAME}.${VLAN}" -p "/run/udhcpc.${IFNAME}.${VLAN}.pid"
  fi
done

eval "python /app/multicast-relay.py --foreground --interfaces ${ARG}"
