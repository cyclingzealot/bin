#!/usr/bin/env bash

#exit when command fails (use || true when a command can fail)
set -o errexit

#exit when your script tries to use undeclared variables
set -o nounset

#(a.k.a set -x) to trace what gets executed
#set -o xtrace

# in scripts to catch mysqldump fails 
set -o pipefail

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"


#Capture everything to log
log=~/log/$__base.log
exec >  >(tee -a $log)
exec 2> >(tee -a $log >&2)



deg2rad () {
        bc -l <<< "$1 * 0.0174532925"
}

rad2deg () {
        bc -l <<< "$1 * 57.2957795"
}

acos () {
        pi="3.141592653589793"
        bc -l <<<"$pi / 2 - a($1 / sqrt(1 - $1 * $1))"
}

distance () {
        earth_radius="3960.00"
        lat_1="$1"
        lon_1="$2"
        lat_2="$3"
        lon_2="$4"
        delta_lat=`bc <<<"$lat_2 - $lat_1"`
        delta_lon=`bc <<<"$lon_2 - $lon_1"`
        lat_1="`deg2rad $lat_1`"
        lon_1="`deg2rad $lon_1`"
        lat_2="`deg2rad $lat_2`"
        lon_2="`deg2rad $lon_2`"
        delta_lat="`deg2rad $delta_lat`"
        delta_lon="`deg2rad $delta_lon`"

        distance=`bc -l <<< "s($lat_1) * s($lat_2) + c($lat_1) * c($lat_2) * c($delta_lon)"`
        distance=`acos $distance`
        distance="`rad2deg $distance`"
        distance=`bc -l <<< "$distance * 60 * 1.1515"`
        distance=`bc <<<"scale=4; $distance / 1"`
        echo $distance
}


if [[ ! -f ~/.homeCoords ]] ; then
	echo "I need a file named ~/.homeCoords with your lat long in degree decimal"
	exit 1
fi

homeCoords=`cat ~/.homeCoords`
homeLat=`echo $homeCoords | cut -d ','  -f 1  | tr -d ' ' `
homeLong=`echo $homeCoords | cut -d ','  -f 2  | tr -d ' ' `

#echo Your lat long is $homeLat,$homeLong

coords=`curl "http://www.geohash.info/srv/feed.php?lat=${homeLat}&lon=${homeLong}" | xml_grep --text_only --cond 'item/description' | cut -c 33-54 | sed 's/°//g' `
destLat=`echo $coords | cut -d ' '  -f 1  | tr -d ' ' `
destLong=`echo $coords | cut -d ' '  -f 2  | tr -d ' ' `

#echo The destination lat long is $destLat,$destLong


dist=`distance $homeLat $homeLong $destLat $destLong | sed 's/\./,/g'`
dist=`printf "%0.0f" "$dist"`


message=''
maxDist=7
compare=`echo "$dist<$maxDist" | bc`
if [[ "$compare" -eq "1" ]] ; then 
	message="Time for geohashing!  The geohash is $dist km away!"
else 
	message="Sorry, geohash is $dist km away"
fi

echo $message
notify-send "$message"
