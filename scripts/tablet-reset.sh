#!/bin/bash

SCRIPTPATH="$(dirname $(readlink -f "$0"))"
cd "$SCRIPTPATH"

REPOPATH="$(git rev-parse --show-toplevel)"

# check if graphics tablet is already plugged in
while read -r directory event filename; do
	if [[ "$filename" =~ ^mouse[1-9]*[0-9]$ ]] && [ "$event" == "CREATE" ]; then
		# wait for device to init
		sleep 4
		bash "$REPOPATH/scripts/recover.sh"
	fi
done < <(inotifywait -e create -q -m /dev/input)
