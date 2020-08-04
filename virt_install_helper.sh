#!/bin/bash

read -p "VM name: " VM_NAME
read -p "OS variant: " OS_VARIANT
read -p "num cpus: " NUM_CPUS
read -p "ram (GB): " RAM
read -p "hdd path (pre-existing image file / block device): " -e DISK_PATH
read -p "cdrom 1 path: " -e CDROM1_PATH
read -p "cdrom 2 path (optional): " -e CDROM2_PATH

RAM=$(($RAM * 1024))


ARGS=(
     --connect "qemu:///system"
     --virt-type kvm
     --name "${VM_NAME}"
     --vcpus "${NUM_CPUS}"
     --ram "${RAM}"
     --memballoon virtio
     --network bridge=virbr0,model=virtio
     --disk path="${DISK_PATH}",bus=virtio
     --cdrom "${CDROM1_PATH}"
     --graphics vnc
     --os-variant "${OS_VARIANT}"
     --boot cdrom
)

if [ -n "${CDROM2_PATH}" ]
then
	ARGS+=(--disk path="${CDROM2_PATH}",device=cdrom)
fi


virt-install "${ARGS[@]}"


#### some practical notes ####
##to install to an non existing image file a size option must be provided
#--disk path=/PATH_TO_IMG,size=100,bus=virtio \

##virtio drivers must be loaded for windows setup to recognize the drives (see below how to retrieve drivers)
##once booted into the installer mount the virtio iso and install virtio scsi controller (folder viostore); when done mount the windows iso again and click refresh
#virsh attach-disk VM_NAME PATH_TO_ISO hda --type cdrom --mode readonly

##to remove an iso from a VM use (yes an empty string is used by intention)
#virsh attach-disk VM_NAME "" hda --type cdrom --mode readonly

##get virtio drivers from the fedora project
##download RPM from
##https://fedorapeople.org/groups/virt/virtio-win/repo/latest/
##convert and extract rpm
#rpm2cpio xxx.rpm | cpio -idmv
##resulting folder will have readymade iso files
