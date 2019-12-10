#!/bin/bash

checker="/var/tmp/checksum"
file="/etc/crontab"
md5hash=$(sudo md5sum $file)

if [ ! -f $file ]; then
	echo "$md5hash" > $checker
	exit 0;
elif [ "$md5hash" != "$(cat $file)" ]; then
	mail -s "File Monitor Report." root <<< '$file has been modified!'
else
	exit 0;
fi
