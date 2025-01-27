#!/usr/bin/bash

shopt -s globstar

while [[ $# -gt 0 ]]; do
	case $1 in
		-h | --help)
			echo "Usage: file-stat <path> [-h|--help]";
			exit
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
  echo "Error: You need to provide a input path"
  echo "Usage: $0 <file_path>"
  exit 1
fi

INPUT_PATH=$1

print_with_tab() {
  while read -r line; do
    printf "\t%s\n" "$line"
  done <<< "$1"
}

print_files_by_type() {
  echo -e "$1" | while read count mime_type; do
    printf "\t%-10s %-20s\n" "$count" "$mime_type"
  done
}

total_files_count=$(find $INPUT_PATH -type f | wc -l)
total_dirs_count=$(find $INPUT_PATH -type d | wc -l)
files_by_mime_types=$(find $INPUT_PATH -type f -exec file --mime-type -b {} + | sort | uniq -c)
files_by_extenstion=$(find $INPUT_PATH -type f | sed -E 's/.*\.(.*)/\1/' | sort | uniq -c | sort -nr)
total_weight=$(du -sh $INPUT_PATH | awk '{print $1}')
empty_files_count=$(find $INPUT_PATH -type f -size 0c | wc -l)
top_files_by_weight=$(find $INPUT_PATH -type f -exec du -h {} + | sort -rh | head -n 5)
top_files_by_update_date=$(find $INPUT_PATH -type f -exec stat --format='%Y %n' {} + | sort -n -r | head -n 5 | awk '{print strftime("%b %d %H:%M", $1), substr($0, index($0,$2))}')
oldest_file=$(find $INPUT_PATH -type f -exec stat --format='%Y %n' {} + | sort -n | head -n 1 | awk '{print strftime("%b %d %H:%M", $1), substr($0, index($0,$2))}')


printf "%-20s %s\n" "Total files count:" "$total_files_count"
printf "%-20s %s\n" "Total dirs count:" "$total_dirs_count"
printf "%-20s %s\n" "Total weight:" "$total_weight"
printf "%-20s %s\n" "Empty files count:" "$empty_files_count"
printf "%-20s %s\n" "Oldest file:" "$oldest_file"

echo -e "\nFiles by mime types:"
print_files_by_type "$files_by_mime_types"

echo -e "\nFiles by extension:"
print_files_by_type "$files_by_extenstion"

echo -e "\nTop 5 files by weight:"
print_with_tab "$top_files_by_weight"

echo -e "\nTop 5 files by update date:"
print_with_tab "$top_files_by_update_date"

