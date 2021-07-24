#!/bin/bash
# Fred Denis -- 
#
set -o pipefail
#
     TS="date "+%Y-%m-%d_%H%M%S""          # A timestamp for a nice output in a logfile
 TMPDIR="/tmp"
    dir=$(mktemp -du fastestfindXXXXXXXXX -p ${TMPDIR})
nbtests=4
nbfiles=100000
#
FIND1="-delete"
FIND2="-exec rm -fr {} \;"
FIND3="| xargs -0 rm -fr"
#
for i in $(seq 1 ${nbtests}); do
    if [[ -f ./cre_files.sh ]]; then
        start=$(date +%s)
        ./cre_files.sh --dir "${dir}" --nb ${nbfiles} > /dev/null
        end=$(date +%s)
        seconds=$(( end - start ))
        printf "\033[1;36m%s\033[m\n" "$($TS) [INFO] create ${nbfiles} files in ${seconds} seconds"
    else
        printf "\033[1;31m%s\033[m\n" "$($TS) [ERROR] Cannot find cre_files.sh"
        exit 123
    fi
    if [[ -d "${dir}" ]]; then
        start=$(date +%s)
        find "${dir}" -type f ${FIND1}  > /dev/null
        end=$(date +%s)
        seconds=$(( end - start ))
        printf "\033[1;36m%s\033[m\n" "$($TS) [INFO] ${FIND1} in ${seconds} seconds"
    else
        printf "\033[1;31m%s\033[m\n" "$($TS) [ERROR] ${dir} does not exist, cannot continue."
        exit 124
    fi
    rm -fr "${dir}"
done
