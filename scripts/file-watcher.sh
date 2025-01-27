#!/usr/bin/bash

shopt -s extglob

LOG_FILE="./watcher.log"
READ=false
OVERWRITE=true

CONFIG_FILE="$HOME/.config/file-watcher/config.conf"

if [ -f "$CONFIG_FILE" ]; then
  . "$CONFIG_FILE"
fi

while [[ $# -gt 0 ]]; do
	case $1 in
		-h | --help)
			echo "Usage: file-watcher <path> [-h|--help] [-r|--read] [-l|--log] [-no|--no-overwrite]";
			exit
			;;
		-l | --log)
			LOG_FILE="$2"
			shift # past argument
			shift # past value

			if [ -z "$LOG_FILE" ]; then
				echo "No log file specified!"
				exit 1
			fi
			;;
		-r | --read)
			READ=true
			shift # past argument
			shift # past value
			;;
		-no | --no-overwrite)
			OVERWRITE=false
			shift # past argument
			shift # past value
			;;
		-* | --*)
			echo -e "Unknown option $1"
			exit 1
			;;
		*)
			POSITIONAL_ARGS+=("$1") # save positional arg
			shift                   # past argument
			;;
	esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

if [ -z "$1" ]; then
  echo "Error: You need to provide a input directory path."
  echo "Usage: $0 <file_path>"
  exit 1
fi

WATCH_DIR=$1

if $READ; then
  EVENTS="attrib,modify,create,delete,move,access"
else
  EVENTS="attrib,modify,create,delete,move"
fi

if $OVERWRITE; then
	echo "" > "$LOG_FILE"
fi

inotifywait -m -r -e $EVENTS "$WATCH_DIR" |
	while read path action file; do
		if [[ "$path$file" == "$LOG_FILE" ]]; then
			continue
		fi

		result="$(date '+%Y-%m-%d %H:%M:%S') - Changes in $path$file: $action"

		echo "$result" >> "$LOG_FILE"
		echo "$result"
	done

