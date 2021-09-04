#!/bin/bash
# by vegetablebird 2019.09.16
# last modified 2021.08.27

UserName=`powershell.exe '$env:UserName' | sed -e 's/\r//g'`
#UserName=`cmd.exe /c "echo %USERNAME%" | sed -e 's/\r//g'`
assets="/mnt/c/Users/$UserName/AppData/Local/Packages/Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy/LocalState/Assets"
#assets=`wslpath "$(wslvar USERPROFILE)"`/AppData/Local/Packages/Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy/LocalState/Assets

save_dir=`cd $(dirname ${BASH_SOURCE[0]}) >/dev/null 2>&1 && pwd`

if [ ! -d $assets ]
then
	echo ERROR: directory not found
	echo From directory: $assets
	exit
fi
if [ ! -e $save_dir ]
then
	echo ERROR: directory not found
	pwd
	ls $save_dir
	ls ~
	ls ~/OneDrive
	ls ~/OneDrive/wallpaper
	echo To directory: $save_dir
	exit
fi

for f in `ls $assets/`
do
	name=${f%%.*}
	short_name=`echo $name | head -c 16`
#	format=`file --brief $assets/$f | awk '{print $1}'`
	format=`file --brief $assets/$f | awk -F',' '{print $1}'`

	if [ "$format" == "JPEG image data" ]
	then
		standard=`file --brief $assets/$f | awk -F',' '{print $2}'`
		if [ "$standard" == " JFIF standard 1.01" ]
		then
			resolution=`file --brief $assets/$f | awk -F"," '{print $(NF-1)}' | sed 's/ //g'`
			N_pixels=`echo $resolution | sed 's/x/*/g' | bc`

			if [ "$N_pixels" -gt 480000 ] # larger than 800x600
			then # found a wallpaper
				suffix=`echo $format | awk '{print tolower($1)}'` # jpeg
				echo " Exist .../Assets/$short_name*, $suffix, $resolution"
				if [ ! -f $save_dir/$resolution/$name.$suffix ]
				then
					echo "Create $save_dir/$resolution/$short_name*.$suffix"
					mkdir -p $save_dir/$resolution/
					cp $assets/$f $save_dir/$resolution/$name.$suffix
				fi
			fi
		else
			echo Unknown JPEG standard: ---$standard---
		fi
	elif [ "$format" == "PNG image data" ] # icon image file
	then
		resolution=`file --brief $assets/$f | awk -F"," '{print $(NF-2)}' | sed 's/ //g'`
		N_pixels=`echo $resolution | sed 's/x/*/g' | bc`

#		echo " Exist .../Assets/$short_name*, $format, $resolution"

		if [ "$N_pixels" -gt 480000 ] # larger than 800x600
		then
			suffix=`echo $format | awk '{print tolower($1)}'` # png
			echo "!! Large PNG file found!! Is it a wallpaper?"
			echo "       $short_name*, $suffix, $resolution"
		fi
	else
		echo Unknown file format: ---$format---
	fi
done

