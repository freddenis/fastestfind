#!/bin/bash
# Fred Denis -- 
#
set -o pipefail
#
     TS="date "+%Y-%m-%d_%H%M%S""          # A timestamp for a nice output in a logfile
 TMPDIR="/tmp"
    dir=$(mktemp -du -p ${TMPDIR})
nbtests=5
nbfiles=100000
declare -A sumup
#
# Find command and options to test
#
FIND="find ${dir} -type f "
OPT1="-delete"
OPT2="-exec rm -f {} \;"
OPT3="| xargs rm -f"
OPT4="| parallel -P0 'rm -f {};'"
#
# Cleanup
#
cleanup() {
    err=$?
    exit ${err}
}
sig_cleanup() {
    printf "\n\033[1;31m%s\033[m\n" "$($TS) [ERROR] I have been killed !" >&2
    printf "\033[1;31m%s\033[m\n" "$($TS) [INFO] Cleaning tempfiles, please give it a minute." >&2
    rm -fr "${dir}"
    exit 666
}
trap     cleanup EXIT
trap sig_cleanup INT TERM QUIT
#
# Usage
#
usage() {
    cat << END
        -n | --nbfiles  )  Number of files to create (default is ${nbfiles})
        -t | --nbtests  )  Number of test of each find option (default is ${nbtests})
        -h | --help     )  Shows this help
END
    exit 123
}
#
# Options
#
  SHORT="t:,n:,h"
   LONG="nbtests:,nbfiles:,help"
options=$(getopt -a --longoptions "${LONG}" --options "${SHORT}" -n "$0" -- "$@")
if [[ $? -ne 0 ]]; then
    printf "\033[1;31m%s\033[m\n" "$($TS) [ERROR] Invalid options provided: $*; use -h for help; cannot continue." >&2
    exit 864
fi
eval set -- "${options}"
while true; do
    case "$1" in
        -n | --nbfiles  )   nbfiles="$2"    ; shift 2 ;;
        -t | --nbtests  )   nbtests="$2"    ; shift 2 ;;
        -h | --help     )   usage           ; shift   ;;
             --         )   shift           ; break   ;;
    esac
done
#
printf "\033[1;36m%s\033[m\n" "********************************************************************************************"
printf "\033[1;36m%s\033[m\n" "Fastestfind test with ${nbfiles} files and file deletion with find option: ${!WHAT}"
printf "\033[1;36m%s\033[m\n" "********************************************************************************************"
for WHAT in OPT1 OPT2 OPT3 OPT4; do
    totalsec=0
    for i in $(seq 1 ${nbtests}); do
        #
        # Create the files
        #
        if [[ -f ./cre_files.sh ]]; then
            start=$(date +%s)
            printf "\033[1;36m%-80s\033[m" "$($TS) [INFO] Creating ${nbfiles} files in ${dir} . . ."
            ./cre_files.sh --dir "${dir}" --nb ${nbfiles} > /dev/null
            end=$(date +%s)
            seconds=$(( end - start ))
            printf "\033[1;36m%s\033[m\n" " ${seconds} seconds"
        else
            printf "\033[1;31m%s\033[m\n" "$($TS) [ERROR] Cannot find cre_files.sh"
            exit 123
        fi
        #
        # Delete the files
        #
        if [[ -d "${dir}"  || -n "${ECHO}" ]]; then
            start=$(date +%s)
            printf "\033[1;36m%-80s\033[m" "$($TS) [INFO] Deleting files with ${!WHAT} option . . ."
            eval ${FIND}${!WHAT}  #> /dev/null
            end=$(date +%s)
            seconds=$(( end - start ))
            printf "\033[1;36m%s\033[m\n" " ${seconds} seconds"
        else
            printf "\033[1;31m%s\033[m\n" "$($TS) [ERROR] ${dir} does not exist, cannot continue."
            exit 124
        fi
        rm -fr "${dir}"
        #
        # For sumup
        # 
        (( totalsec+=seconds ))
        if (( i == nbtests )); then
#            echo "Average ${WHAT}" $(( totalsec/nbtests ))
            sumup["${WHAT}"]=$(( totalsec/nbtests ))
        fi
    done
done

printf "\n"
printf " %-15s|" "find option"
for X in ${!sumup[@]}; do
    printf " %-20s|" "${!X}"
done
printf "\n"
printf " %-15s|" "Time (seconds)"
for X in ${!sumup[@]}; do
    printf " %-20s|" "${sumup[$X]}"
done
printf "\n"
