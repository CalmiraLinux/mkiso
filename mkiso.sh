#!/usr/bin/bash
# Скрипт для создания LiveUSB образа Calmira GNU/Linux
# Форк утилиты из Olean Linux
# (C) 2021 Михаил Краснов <linuxoid85@gmail.com>

## SYNOPSIS
# mkiso.sh DISTRO OUTPUT


##############
## Checking ##
##############

if [ $(id -u) != 0 ]; then
	echo "ERROR: $0 script need to run as root!"
	exit 1
fi

if [ $# < 2 ]; then
	echo "ERROR: Few command line arguments!"
	exit 1
fi

if [ "$(mksquashfs 2>&1 | grep "Xdict-size")" = "" ]; then
   echo "ERROR: mksquashfs (from 'squashfs-tools' package) not found or doesn't support xz compressing mode, aborting, no changes made"
   echo "You may consider installing squashfs-tools package"
   exit 1
fi

trap "exit 1" SIGHUP SIGINT SIGQUIT SIGTERM

##############################
## Default parameter values ##
##############################

CALMVERSION="1.1rc2"

CWD=$PWD
WDIR=/tmp/calmiso
ISOLINUXDIR=$CWD/livecd/isolinux
DISTRONAME="Calmira LX4"
LABEL=CalmiraLiveCD
CALM_ROOT=$1

if [ -z "$2" ]; then
	OUTPUT="calmira-$CALMVERSION.iso"
else
	OUTPUT="$2"
fi

isolinux_files="chain.c32 isolinux.bin ldlinux.c32 libutil.c32 reboot.c32 menu.c32
isohdpfx.bin isolinux.cfg libcom32.c32 poweroff.c32"

####################################
## Reading the configuration file ##
####################################

for file in "/etc/mkiso.conf" "~/.config/mkiso.conf"; do
	if [ -f "$file" ]; then
		source $file
	fi
done
unset file


# Preparing...

rm    $WDIR
mkdir $WDIR


# prepare isolinux in working dir
mkdir $WDIR/{filesystem,isolinux,boot}

for file in $isolinux_files; do
	cp $ISOLINUXDIR/$file $WDIR/isolinux
done

echo "$DISTRONAME" > $WDIR/isolinux/venomlive
[ -d livecd/virootfs ] && cp -aR livecd/virootfs $WDIR

cp $CALM_ROOT/boot/{vmlinuz-*-calm-kernel,vmlinuz} $WDIR/boot/

# Создание и хранение root.sfs (сквоша системы) сделано в текущей
# директории на всякий случай, чтобы при изменении в файлах
# загрузчика (и прочих не относящихся к системе) не пересобирать
# всю систему в сквош, а скопировать готовый
mksquashfs $CALM_ROOT root.sfs           \
	-b 1048576 -comp xz -Xdict-size 100% \
	-e $CALM_ROOT/tmp/*                  \
	-e $CALM_ROOT/usr/src/*
	
cp root.sfs $WDIR/filesystem

if [ -f "$OUTPUT" ]; then
	rm -rf $OUTPUT
fi

# Make iso
xorriso -as mkisofs                              \
		-r -J -joliet-long                       \
		-l -cache-inodes                         \
		-isohybrid-mbr $ISOLINUXDIR/isohdpfx.bin \
		-partition_offset 16                     \
		-volid "$LABEL"                          \
		-b isolinux/isolinux.bin                 \
		-c isolinux/boot.cat                     \
		-no-emul-boot                            \
		-boot-load-size 4                        \
		-boot-info-table                         \
		-o $OUTPUT                               \
		$WDIR

rm -rvf $WDIR