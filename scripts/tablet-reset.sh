#!/bin/bash

REPOPATH="$(git rev-parse --show-toplevel)"

# check if graphics tablet is already plugged in
while read -r directory event filename; do
	if [[ "$filename" =~ ^mouse[1-9]*[0-9]$ ]] && [ "$event" == "CREATE" ]; then
		# wait for device to init
		sleep 2
		bash "$REPOPATH/scripts/recover.sh"
	fi
done < <(inotifywait -e create -q -m /dev/input)
