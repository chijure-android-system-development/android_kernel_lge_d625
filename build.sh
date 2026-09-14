#!/bin/bash

daytime=$(date +%d"-"%m"-"%Y"_"%H"-"%M)

location=.
vendor=lge

export target=d625
export defconfig=${defconfig:-pda_android_defconfig}

export compiler=~/arm-eabi-4.6/bin/arm-eabi-

cd $location
export ARCH=arm
export CROSS_COMPILE=$compiler
if [ -z "$clean" ]; then
read -p "do make clean mrproper?(y/n)" clean
fi # [ -z "$clean" ]
case "$clean" in
y|Y ) echo "cleaning..."; make clean mrproper;;
n|N ) echo "continuing...";;
* ) echo "invalid option"; sleep 2 ; build.sh;;
esac

echo "now building the kernel"

# Start time tracking
start_time=$(date +%s)

rm -f arch/arm/boot/zImage
make $defconfig
defconfig_status=$?
set -o pipefail
if [ "$defconfig_status" -eq 0 ]; then
	make HOSTCFLAGS="-fcommon" -j$(nproc --all) 2>&1 | tee build.log
	build_status=${PIPESTATUS[0]}
else
	build_status=$defconfig_status
fi
set +o pipefail


# Calculate compilation time
end_time=$(date +%s)
compilation_time=$((end_time - start_time))
minutes=$((compilation_time / 60))
seconds=$((compilation_time % 60))


if [ "$build_status" -eq 0 ] && [ -f arch/arm/boot/zImage ]; then

echo "==============================================="
echo "Compilation successful!"
echo "Time elapsed: ${minutes} minutes and ${seconds} seconds"
echo "==============================================="
echo "zImage at arch/arm/boot/zImage"

else # [ -f arch/arm/boot/zImage ]
echo "==============================================="
echo "Build failed after ${minutes} minutes and ${seconds} seconds"
echo "==============================================="
fi # [ -f arch/arm/boot/zImage ]
