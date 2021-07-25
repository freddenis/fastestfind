#!/bin/bash
# Fred Denis -- 
#
set -o pipefail
#
     TS="date "+%Y-%m-%d_%H%M%S""          # A timestamp for a nice output in a logfile
 TMPDIR="/tmp"
    dir=$(mktemp -du fastestfindXXXXXXXXX -p ${TMPDIR})
nbtests=5
nbfiles=100000
#
FIND="find ${dir} -type f "
OPT1="-delete"
OPT2="-exec rm -f {} \;"
OPT3="| xargs -0 -n 10 rm -f"
OPT3="| xargs rm -f"
#
#for WHAT in OPT1 OPT2 OPT3; do
for WHAT in OPT3; do
#    echo ${!WHAT}
    echo ${FIND}${!WHAT}
    printf "\033[1;36m%s\033[m\n" "********************************************************************************************"
    printf "\033[1;36m%s\033[m\n" "Fastestfind test with ${nbfiles} files and file deletion with find option: ${!WHAT}"
    printf "\033[1;36m%s\033[m\n" "********************************************************************************************"
    for i in $(seq 1 ${nbtests}); do
        #
        # Create the files
        #
        if [[ -f ./cre_files.sh ]]; then
            start=$(date +%s)
            printf "\033[1;36m%s\033[m" "$($TS) [INFO] Creating ${nbfiles} in ${dir} . . ."
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
            echo ${FIND}${!WHAT}
            eval ${FIND}${!WHAT}  #> /dev/null
            end=$(date +%s)
            seconds=$(( end - start ))
            printf "\033[1;36m%s\033[m\n" "$($TS) [INFO] ${!WHAT} in ${seconds} seconds"
        else
            printf "\033[1;31m%s\033[m\n" "$($TS) [ERROR] ${dir} does not exist, cannot continue."
            exit 124
        fi
        rm -fr "${dir}"
    done
done
