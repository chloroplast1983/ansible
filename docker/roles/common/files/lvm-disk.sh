#!/bin/bash

DISK=$1
PARTION=$2
SIZE=$3

CHECK_EXIST=`fdisk -l 2> /dev/null | grep -o "$DISK"`
[ ! "$CHECK_EXIST" ] && { echo "Error: Disk is not found !"; exit 1;}

CHECK_DISK_EXIST=`fdisk -l 2> /dev/null | grep -o "$DISK$PARTION"`
[ ! "$CHECK_DISK_EXIST" ] || { echo "WARNING: ${CHECK_DISK_EXIST} is Partition already !"; exit 0;}

if [ ${PARTION} -gt 1 ]; then
fdisk $DISK<<EOF
n
p
$PARTION

$SIZE
t

8e
wq
EOF
else
fdisk $DISK<<EOF
n
p
$PARTION

$SIZE
t
8e
wq
EOF
fi
