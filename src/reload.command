#!/bin/bash

#  Reload VM
#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}"/functions.sh

# get App's Resources folder
res_folder=$(cat ~/coreos-osx/.env/resouces_path)

# path to the bin folder where we store our binary files
export PATH=${HOME}/coreos-osx/bin:$PATH

# get password for sudo
my_password=$(security find-generic-password -wa coreos-osx-app)
# reset sudo
sudo -k

### Stop VM
echo " "
echo "Stopping VM ..."
# send halt to VM
echo -e "$my_password\n" | sudo -Sv > /dev/null 2>&1
sudo "${res_folder}"/bin/corectl halt core-01

sleep 5

# Start VM
cd ~/coreos-osx
echo " "
echo "Starting VM ..."
echo -e "$my_password\n" | sudo -Sv > /dev/null 2>&1
#
sudo "${res_folder}"/bin/corectl load settings/core-01.toml 2>&1 | tee ~/coreos-osx/logs/vm_reload.log
CHECK_VM_STATUS=$(cat ~/coreos-osx/logs/vm_reload.log | grep "started")
#
if [[ "$CHECK_VM_STATUS" == "" ]]; then
    echo " "
    echo "VM have not booted, please check '~/coreos-osx/logs/vm_reload.log' and report the problem !!! "
    echo " "
    pause 'Press [Enter] key to continue...'
    exit 0
else
    echo "VM successfully started !!!" >> ~/coreos-osx/logs/vm_reload.log
fi

# check if /Users/homefolder is mounted, if not mount it
"${res_folder}"/bin/corectl ssh core-01 'source /etc/environment; if df -h | grep ${HOMEDIR}; then echo 0; else sudo systemctl restart ${HOMEDIR}; fi' > /dev/null 2>&1
echo " "

# get VM's IP
vm_ip=$("${res_folder}"/bin/corectl q -i core-01)
# save VM's IP
"${res_folder}"/bin/corectl q -i core-01 | tr -d "\n" > ~/coreos-osx/.env/ip_address
#

echo "CoreOS VM was reloaded !!!"
echo ""
pause 'Press [Enter] key to continue...'
