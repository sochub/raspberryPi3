#!/bin/bash

export WorkPath=`pwd`

## Root Password
for ((i = 0; i < 5; i++)); do
	PASSWD=$(whiptail --title "Raspbian build system" \
		--passwordbox "Enter root password. Don't use root or sudo run it" \
		10 60 3>&1 1>&2 2>&3)
	if [ $i = "4" ]; then
		whiptail --title "Note Qitas" --msgbox "Invalid password" 10 40 0	
		exit 0
	fi

	sudo -k
	if sudo -lS &> /dev/null << EOF
$PASSWD
EOF
	then
		i=10
	else
		whiptail --title "Raspbian build System" --msgbox "Invalid password, Pls input corrent password" \
		10 40 0	--cancel-button Exit --ok-button Retry
	fi
done

echo $PASSWD | sudo ls &> /dev/null 2>&1


function apt_install()
{
	sudo apt install -y git bison flex libssl-dev
	sudo apt autoremove -y 
}

function pi3_config()
{
	KERNEL=kernel7
	make bcm2709_defconfig
}


function get_gcc()
{
	str="arm-linux-gnueabihf-gcc-ar :    "
	ret=`whereis arm-linux-gnueabihf-gcc-ar`
	if [ ${#ret} -lt ${#str} ]; then
		if [ -f  $WorkPath/scripts/toolchain.sh ]; then
			chmod +x $WorkPath/scripts/toolchain.sh
			$WorkPath/scripts/toolchain.sh 
			source  ~/.bashrc
		else
			echo -e "no shell toolchain.sh \n${Line}"
		fi
	else
		echo -e "done config toolchain gcc\n${Line}"
	fi
}

function make_all()
{
	make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- zImage modules dtbs
}


OPTION=$(whiptail --title "Raspbian build system" \
	--menu "$MENUSTR" 20 60 12 --cancel-button Finish --ok-button Select \
	"0"   "AUTO all" \
	"1"   "update src" \
	"2"   "make all" \
	"3"   "flash image" \
	3>&1 1>&2 2>&3)

# config port user mod	
apt_install
port_config

if [ $OPTION = '0' ]; then
	clear
	echo -e "AUTO all\n${Line}"

	exit 0
elif [ $OPTION = '1' ]; then
	clear
	echo -e "update src\n${Line}"

	exit 0
elif [ $OPTION = '2' ]; then
	clear
	echo -e "make all\n${Line}"

	exit 0
elif [ $OPTION = '3' ]; then
	clear
	echo -e "flash image\n${Line}"

	exit 0	
else
	whiptail --title "Raspbian build system" \
		--msgbox "Please select correct option" 10 50 0
	exit 0
fi



exit 0
