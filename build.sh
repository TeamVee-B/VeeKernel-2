#!/bin/bash
# Base by cybojenix <anthonydking@gmail.com>
# ReWriten by Caio Oliveira aka Caio99BR <caiooliveirafarias0@gmail.com>
# Rashed for the base of zip making
# And the internet for filling in else where

# You need to download https://github.com/TeamVee/android_prebuilt_toolchains
# Clone in the same folder as the kernel

# Clean - Start

cleanzip() {
rm -rf zip-creator/*.zip
rm -rf zip-creator/kernel/zImage
rm -rf zip-creator/system/lib/modules
cleanzipcheck="Done"
zippackagecheck=""
}

cleankernel() {
echo "Cleaning..."
make clean mrproper &> /dev/null
cleankernelcheck="Done"
buildprocesscheck=""
target=""
serie=""
variant=""
}

# Clean - End

# Main Process - Start

maindevice() {
devicechoice
devicechoicer
}

devicechoice() {
clear
echo ""
echo "Script says: Choose to which you will build"; sleep .5
echo "Caio99BR says: 1) L3 II Single"; sleep .5
echo "Caio99BR says: 2) L3 II Dual"; sleep .5
}

devicechoicer() {
read -p "Choice: " -n 1 -s choice
case "$choice" in
	1 ) export target="L3"; export serie="II"; export variant="Single"; export defconfig=cyanogenmod_vee3_defconfig;;
	2 ) export target="L3"; export serie="II"; export variant="Dual"; export defconfig=cyanogenmod_vee3ds_defconfig;;
	* ) echo "$choice - This option is not valid"; sleep 2; devicechoice;;
esac
echo "$choice - $target $serie $variant"; sleep .5
make $defconfig &> /dev/null
}

maintoolchain() {
if [ "$CROSS_COMPILE" == "" ]; then
	clear
	echo ""
	echo "Caio99BR says: Checking if you have TeamVee Prebuilt Toolchains"; sleep 1
	if [ -d ../android_prebuilt_toolchains ]; then
		toolchainchoice
	else
		clear
		echo ""
		echo "Caio99BR says: You don't have TeamVee Prebuilt Toolchains"; sleep .5
		echo ""
		echo "Script says: Please specify a location"; sleep 1
		echo "Script says: and the prefix of the chosen toolchain at the end"; sleep 1
		echo "Caio99BR says: GCC 4.6 ex. ../arm-eabi-4.6/bin/arm-eabi-"; sleep 2
		toolchainplace
	fi
else
	clear
	echo ""
	echo "Script says: You want to set a new toolchain place?"
	read -p "Script says: Enter any key for Continue or y for Yes: " -n 1 -s newsettoolchain
	case $newsettoolchain in
		y) export CROSS_COMPILE=""; maintoolchain;;
		*) echo "Continuing..."; echo "Current Toolchain: $CROSS_COMPILE";;
	esac
fi
}

toolchainchoice() {
toolchainchoice1
toolchainchoice2
echo "$CROSS_COMPILE"; sleep .5
}

toolchainchoice1() {
echo ""
echo "Script says: Choose the toolchain"; sleep .5
echo "Google GCC - 1) 4.7   | 2) 4.8"; sleep .5
echo "Linaro GCC - 3) 4.6.4 | 4) 4.7.4"; sleep .5
echo "Linaro GCC - 5) 4.8.4 | 6) 4.9.3"; sleep .5
}

toolchainchoice2() {
read -p "Choice: " -n 1 -s toolchain
case "$toolchain" in
	1 ) export CROSS_COMPILE="../android_prebuilt_toolchains/arm-eabi-4.7/bin/arm-eabi-";;
	2 ) export CROSS_COMPILE="../android_prebuilt_toolchains/arm-eabi-4.8/bin/arm-eabi-";;
	3 ) export CROSS_COMPILE="../android_prebuilt_toolchains/arm-unknown-linux-gnueabi-linaro_4.6.4-2013.05/bin/arm-unknown-linux-gnueabi-";;
	4 ) export CROSS_COMPILE="../android_prebuilt_toolchains/arm-unknown-linux-gnueabi-linaro_4.7.4-2013.12/bin/arm-unknown-linux-gnueabi-";;
	5 ) export CROSS_COMPILE="../android_prebuilt_toolchains/arm-linux-gnueabi-linaro_4.8.4-2014.11/bin/arm-linux-gnueabi-";;
	6 ) export CROSS_COMPILE="../android_prebuilt_toolchains/arm-cortex-linux-gnueabi-linaro_4.9.3-2015.03/bin/arm-cortex-linux-gnueabi-";;
	* ) echo "$toolchain - This option is not valid"; sleep 2; toolchainchoice2;;
esac
}

toolchainplace() {
read -p "Place: " CROSS_COMPILE
echo "$CROSS_COMPILE"; sleep .5
}

# Main Process - End

# Build Process - Start

buildprocess() {
echo "Building..."; sleep 1
echo
START=$(date +"%s")
make -j4
END=$(date +"%s")
BUILDTIME=$(($END - $START))
buildprocesscheck="Done"
cleankernelcheck=""
}

zippackage() {
if [ -f arch/arm/boot/zImage ]; then
	echo "Script says: Ziping..."
	if [ "$variant" == "Dual" ]; then
		todual  &> /dev/null
	fi

	mkdir -p zip-creator/system/lib/modules  &> /dev/null
	cp arch/arm/boot/zImage zip-creator/kernel  &> /dev/null
	find . -name *.ko | xargs cp -a --target-directory=zip-creator/system/lib/modules/  &> /dev/null

	zipfile="$customkernel-$target-$serie-$variant-$version.zip"

	cd zip-creator
	zip -r $zipfile * -x *kernel/.gitignore* &> /dev/null
	cd ..

	if [ "$variant" == "Dual" ]; then
		tosingle  &> /dev/null
	fi
else
	echo "Script says: Build Kernel First!"
fi
zippackagecheck="Done"
cleanzipcheck=""
}

todual() {
sed 's/Single/Dual/' zip-creator/META-INF/com/google/android/updater-script > zip-creator/META-INF/com/google/android/updater-script-temp
rm zip-creator/META-INF/com/google/android/updater-script
mv zip-creator/META-INF/com/google/android/updater-script-temp zip-creator/META-INF/com/google/android/updater-script
}

tosingle() {
sed 's/Dual/Single/' zip-creator/META-INF/com/google/android/updater-script > zip-creator/META-INF/com/google/android/updater-script-temp
rm zip-creator/META-INF/com/google/android/updater-script
mv zip-creator/META-INF/com/google/android/updater-script-temp zip-creator/META-INF/com/google/android/updater-script
}

# Build Process - End

# Check - Start

emptycheck() {
cleanzipcheck=""
cleankernelcheck=""
buildprocesscheck=""
zippackagecheck=""
}

# Check - End
customkernel=VeeKernel
version=Stable

# Menu - Start

buildsh() {
kernelversion=`cat Makefile | grep VERSION | cut -c 11- | head -1`
kernelpatchlevel=`cat Makefile | grep PATCHLEVEL | cut -c 14- | head -1`
kernelsublevel=`cat Makefile | grep SUBLEVEL | cut -c 12- | head -1`
kernelname=`cat Makefile | grep NAME | cut -c 8- | head -1`
while :
do
	clear
	echo ""
	echo "Caio99BR says: This is an open source script, feel free to use and share it."
	echo "Caio99BR says: Simple $customkernel Build Script."
	echo "Caio99BR says: $kernelversion.$kernelpatchlevel.$kernelsublevel - $kernelname"
	echo
	echo "Clean:"
	echo "1) Last Zip Package ( $cleanzipcheck)"
	echo "2) Last Kernel ( $cleankernelcheck)"
	echo
	echo "Main Process:"
	echo "3) Device Choice ($target$serie $variant)"
	echo "4) Toolchain Choice ($CROSS_COMPILE)"
	echo
	echo "Build Process:"
	echo "5) Build Kernel ( $buildprocesscheck)"
	echo "6) Build Zip Package ( $zippackagecheck)"
	echo
	if ! [ "$BUILDTIME" == "" ]; then
	echo -e "\033[32mBuild Time: $(($BUILDTIME / 60)) minutes and $(($BUILDTIME % 60)) seconds.\033[0m"
	echo
	fi
	echo "q) Quit"
	read -n 1 -p "Choice: " -s x
	case $x in
		1) cleanzip;;
		2) cleankernel;;
		3) maindevice;;
		4) maintoolchain;;
		5) buildprocess;;
		6) zippackage;;
		q) echo "Ok, bye!"; sleep 1; echo; emptycheck; exit 0
	esac
done
}

# Menu - End

if [ ! -e build.sh ]; then
	echo
	echo "Ensure you run this file from the SAME folder as where it was"
	echo "installed, otherwise the build script will have problems running the"
	echo "commands.  After you 'cd' to the correct folder, start the build script"
	echo "with the ./build.sh command, NOT with any other command or method!"; sleep 2
	exit 0
fi

buildsh
