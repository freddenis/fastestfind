#!/bin/bash
# Fred Denis -- 
#
set -o pipefail
#
      TS="date "+%Y-%m-%d_%H%M%S""     # A timestamp for a nice output in a logfile
  TMPDIR="/tmp"
     dir=$(mktemp -du -p ${TMPDIR})
 nbtests=5
 nbfiles=100000
     COL=15                            # Size of the first column of the output (description)
linesize="${COL}"                      # For the output table
declare -A sumup
declare -A colsize 
#
# Find command and options to test
#
FIND="find ${dir} -type f "
OPT1="| xargs rm -f"
OPT2="-exec rm -f {} \;"
OPT3="-delete"
OPT4="| parallel rm -f {};"
list_options=('OPT1' 'OPT2' 'OPT3' 'OPT4')  # List of options to test
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
                       You can use k for thousands (10k=10000) and m for millions (2m=2 millions)
    -t | --nbtests  )  Number of test of each find option (default is ${nbtests})
    -h | --help     )  Shows this help
END
    exit 123
}
#
# Print a line of "-" in color
#
print_a_line() {
     l_size=$1 
    l_color=$2       # (31=red; 32=green; 33=yellow; 34=blue; 35=purple; 36=teal; 37=white)
    if [[ -z "${l_size}" ]]; then return 0; fi
    if [[ -z "${l_color}" ]]; then l_color=37; fi
    printf "\033[1;${l_color}m" ""          # Begin color
    for i in $(seq 1 "${l_size}"); do
        printf "%s" "-"
    done
    printf "\033[m"                         # End color
    printf "\n"
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
print_a_line 70
printf "%s\n" "Fastestfind test with ${nbfiles} files and file deletion with find option: ${!WHAT}"
print_a_line 70
for nb in $(echo "${nbfiles}" | sed 's/,/ /g'); do
  #for WHAT in OPT1 OPT2 OPT3 OPT4; do
  for WHAT in "${list_options[@]}"; do
    totalsec=0
    for i in $(seq 1 ${nbtests}); do
        #
        # Create the files
        #
        if [[ -f ./cre_files.sh ]]; then
            start=$(date +%s)
            printf "\033[1;36m%-80s\033[m" "$($TS) [INFO] Creating ${nb} files in ${dir} . . ."
            ./cre_files.sh --dir "${dir}" --nb ${nb} > /dev/null
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
            printf "\033[1;36m%-80s\033[m" "$($TS) [INFO] Deleting files using ${!WHAT}. . ."
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
        # sumup
        # 
        (( totalsec+=seconds ))
        if (( i == nbtests )); then
            # A bit of cleanup to remove the potential "| " of each command which dont
            # look nice in the output table
            W="${!WHAT}"                     # To adapt the column size of the output table
            W="${W/|/}"
            W=$(echo "${W}" | sed s'/^ //')  # In case there is a leading space
            sumup["${nb}","${W}"]=$(( totalsec/nbtests ))
            colsize["${W}"]="${#W}"
            (( linesize+=${colsize["${W}"]} ))
        fi
    done # End of each test
  done   # End of for WHAT in opt
done
# A sumup of number of lines and number of tests
printf "\n"
printf "%s" "Fastestfind test using ${nbfiles} files and ${nbtests} tests"
(( linesize+=(${#list_options[@]}*3) ))
# Print the find options used
printf "\n"
print_a_line "${linesize}"
printf "%-${COL}s|" "find option"
for X in "${!sumup[@]}"; do
    N=$(echo "${X}" | awk -F "," '{print $1}')
    O=$(echo "${X}" | awk -F "," '{print $2}')
    printf " %-${colsize["${O}"]}s |" "${O}"
done
printf "\n"
# Print the seconds
printf "%-${COL}s|" "Time (seconds)"
for X in "${!sumup[@]}"; do
    O=$(echo "${X}" | awk -F "," '{print $2}')
    C=${colsize["${O}"]}        # Column size
    S=${#sumup[$X]}             # Size of number of seconds
    R=$(( (C-S)/2 ))
    L=$(( C-S-R ))
    printf " %${L}s%-${S}s%${R}s |" "" "${sumup[$X]}" ""
done
printf "\n"
print_a_line "${linesize}"
