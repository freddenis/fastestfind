#!/bin/bash
# Fred Denis -- 
#
set -o pipefail
#
# Default values
#
    TS="date "+%Y-%m-%d_%H%M%S""          # A timestamp for a nice outut in a logfile
TMPDIR="/tmp"
   dir=$(mktemp -du fastestfindXXXXXXXXX -p ${TMPDIR})
  size=1024
    nb=100000
  part=10
 start=$(date +%s)
#
# Cleanup
#
cleanup() {
        err=$?
        end=$(date +%s)
    seconds=$(( end - start ))
    printf "\n"
    printf "\t\033[1;32m%s\033[m\n" $nb" files have been successfully created in "$seconds" seconds."
    exit ${err}
}
sig_cleanup() {
    printf "\033[1;31m%s\033[m\n" "$($TS) [ERROR] I have been killed !" >&2
    printf "\033[1;31m%s\033[m\n" "$($TS) [INFO] Cleaning tempfiles" >&2
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
	-d:	Directory where to create the files
	-n:	Number of files to create
	-f:	Force drop the directory if already exists
	-h:	Help
END
	exit 123
}
#
# Options
#
SHORT="d:,n:,h"
 LONG="dir:,nb:,help"
options=$(getopt -a --longoptions "${LONG}" --options "${SHORT}" -n "$0" -- "$@")
if [[ $? -ne 0 ]]; then
    printf "\033[1;31m%s\033[m\n" "$($TS) [ERROR] Invalid options provided: $*; use -h for help; cannot continue." >&2
    exit 864
fi
eval set -- "${options}"
while true; do
    case "$1" in
        -d | --dir   )   dir="$2"        ; shift 2 ;;
        -n | --nb    )    nb="$2"        ; shift 2 ;;
        -h | --help  )   usage           ; shift   ;;
             --      )   shift           ; break   ;;
    esac
done

incr=$(( nb / part ))

if [[ ! -d ${dir} ]]; then
    mkdir -p ${dir}
    if [ $? -eq 0 ]; then
        printf "\t\033[1;36m%s\033[m\n" "Directory ${dir} successfully created."
    else
        printf "\t\033[1;31m%s\033[m\n" "Could not create ${dir}; cannot continue."
        exit 123
    fi
else
    printf "\t\033[1;33m%s\033[m\n" "${dir} already exists; please specify a non existing directory (-d option); cannot continue."
    exit 124
fi

start=$(date +%s)
printf "\t\033[1;37m%s\033[m\n" "Let's create "$nb" files :"
printf "\t\033[1;37m%s\033[m\n" "--------------------------"

cd ${dir}
for i in $(seq 1 $part); do
    (dd if=/dev/random bs=$size count=$incr | split -b $size --additional-suffix=$i) > /dev/null 2>&1
    pct=$(( i * part ))
#   echo $pct
    printf "\t\033[1;34m%s\033[m" $pct"%"
done
cd - > /dev/null 2>&1
