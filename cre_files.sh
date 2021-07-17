#!/bin/bash
#
#
#
# Default values
#
 dir="tmp"
size=1024
  nb=100000
part=10


usage()
{
cat << END
	-d:	Directory where to create the files
	-n:	Number of files to create
	-f:	Force drop the directory if already exists
	-h:	Help
END
	exit 123
}

while getopts "d:n:fh" OPT; do
        case ${OPT} in
        d)     dir="${OPTARG}"					;;
        n)      nb=${OPTARG}                           		;;
	f)   force="yes"					;;
        h)      usage                                           ;;
        \?) echo "Invalid option: -$OPTARG" >&2; usage          ;;
        esac
done

incr=$(( nb / part ))

if [[ ! -d ${dir} ]]
then
	mkdir -p ${dir}
	if [ $? -eq 0 ] 
	then
		printf "\t\033[1;36m%s\033[m\n" "Directory ${dir} successfully created."
	else
		printf "\t\033[1;31m%s\033[m\n" "Could not create ${dir}; cannot continue."
		exit 123
	fi
else
#	if [[ "${force}" = "yes" ]]
#	then
#		rm -fr ${dir}
#		printf "\t\033[1;36m%s\033[m\n" "Directory ${dir} successfully deleted as -f was specified."
#	else
		printf "\t\033[1;33m%s\033[m\n" "${dir} already exists; please specify a non existing directory (-d option); cannot continue."
		exit 124
#	fi
	
fi

start=$(date +%s)
printf "\t\033[1;37m%s\033[m\n" "Let's create "$nb" files :"
printf "\t\033[1;37m%s\033[m\n" "--------------------------"

cd ${dir}
for i in `seq 1 $part`
do
        (dd if=/dev/random bs=$size count=$incr | split -b $size --additional-suffix=$i) > /dev/null 2>&1
        pct=$(( i * part ))
#       echo $pct
        printf "\t\033[1;34m%s\033[m" $pct"%"
done
cd - > /dev/null 2>&1
end=$(date +%s)
seconds=$(( end - start ))
printf "\n"
printf "\t\033[1;32m%s\033[m\n" $nb" files have been successfully created in "$seconds" seconds."
