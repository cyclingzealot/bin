#!/bin/bash

order="block"

if [[ "$1" == "up" ]]; then
	order="unblock"
fi

set -x
sudo rfkill $order bluetooth
set +x


