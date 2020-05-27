#!/bin/bash -vx

if [ ! -f $PT_base_os_vmx_file ]; then
  echo "Error: $PT_base_os_vmx_file not found" 2>&1
  exit 1
fi

vmrun_exec=$(command -v vmrun)
if [ ! -f $vmrun_exec ]; then 
  echo "\nError: \'vmrun\' executable not found" 2>&1
  exit 1
fi

# create the clone vm directory "/home/foo/vmware/ubuntu18/ubuntu18.vmx" to 
# "/home/foo/vmware/../pe-2019.1.1/pe-2019.1.1.vmx"
parent_dir=$(dirname "$PT_base_os_vmx_file")
cloned_vm_name="$PT_pe_fqdns"
cloned_vmx_file=$(echo -n "$parent_dir/../$cloned_vm_name/$cloned_vm_name.vmx")
#echo "$cloned_vmx_file $cloned_vm_name" 2>&1

#create a clone of the base OS VM
vmrun -T ws clone "$PT_base_os_vmx_file" "$cloned_vmx_file" linked  -cloneName="$cloned_vm_name" 
if [ $? -ne 0 ]; then
  echo "Error: vmrun clone command failed."
  exit 1
fi

# sanity check if the cloned vmx file was created
if [ ! -f $cloned_vmx_file ]; then
  echo "Error: Something bad happened $cloned_vmx_file was not created."
  exit 1
fi

# start the cloned VM
vmrun -T ws start "$cloned_vmx_file" gui
if [ $? -ne 0 ]; then
  echo "Error: vmrun start command failed."
  exit 1
fi

# wait for the OS to boot
sleep 25

# create a temp file containing commands to start DHCP with a new hostname, reboot
temp_file="/tmp/run_commands.sh"
echo "hostnamectl set-hostname $cloned_vm_name" > $temp_file
echo "sed -i 's/ONBOOT=no/ONBOOT=yes/' /etc/sysconfig/network-scripts/ifcfg-ens33" >> $temp_file
echo "dhclient -v" >> $temp_file
echo 'reboot -h now' >> $temp_file
vmrun -T ws -gu rajesh -gp rajesh12 copyFileFromHostToGuest $cloned_vmx_file $temp_file $temp_file
vmrun -T ws -gu root -gp rajesh12 runProgramInGuest $cloned_vmx_file -noWait /bin/bash $temp_file
echo "Info: Configured networking on $cloned_vmx_file and rebooting"
rm -f $temp_file

# give time for the VM to reboot with new hostname
sleep 40
 