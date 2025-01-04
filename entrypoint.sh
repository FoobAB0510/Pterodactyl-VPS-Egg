#!/bin/bash

sleep 2
tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/var/run/tailscale/tailscaled.sock &
sleep 2

tailscale up --auth-key=tskey-auth-kZey9nf7af11CNTRL-QKxPzzCTLwA7baku5NvnwAYaFXtmqvUw || exit 1

export INTERNAL_IP=$(ip route get 1 | awk '{print $NF;exit}')

cd /home/container

MODIFIED_STARTUP=$(eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g'))

if [ ! -e "$HOME/.installed" ]; then
    /usr/local/bin/proot \
    --rootfs="/" \
    -0 -w "/root" \
    -b /dev -b /sys -b /proc -b /etc/resolv.conf \
    --kill-on-exit \
    /bin/bash "/install.sh" || exit 1
fi

bash /helper.sh