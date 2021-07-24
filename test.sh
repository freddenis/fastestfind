#!/bin/bash

 TMPDIR="/tmp"
    dir=$(mktemp -du fastestfindXXXXXXXXX -p ${TMPDIR})
nbtests=4
nbfiles=1000

FIND1="-delete"
FIND2="-exec rm -fr {} \;"
FIND3="| xargs -0 rm -fr"

#COMMAND1="time find ${dir} -type f -delete"
#COMMAND2="time find ${dir} -type f -exec rm -fr {} \;"
#COMMAND3="time find ${dir} -type f | xargs -0 rm -fr"

for i in $(seq 1 ${nbtests}); do
#    echo $i
    ./cre_files --dir ${dir} --nb ${nbfiles} > dev/null
    [[ -f ${dir} ]] && find ${dir} -type f ${FIND1}  #> /dev/null
    rm -fr "${dir}"
done
