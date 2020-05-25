#!/bin/bash -vx

if [ ! -f $PT_base_os_vmx_file ]; then
  echo "Error: $PT_base_os_vmx_file not found" 2>&1
  exit 1
fi

vmrun_exec = command -v vmrun 
if [ ! -f $vmrun_exec ]; then 
  echo "\nError: \'vmrun\' executable not found" 2>&1
  exit 1
fi

# create the clone vm directory "/home/foo/vmware/ubuntu18/ubuntu18.vmx" to 
# "/home/foo/vmware/../pe-2019.1.1/pe-2019.1.1.vmx"
parent_dir=$(dirname "$PT_base_os_vmx_file")
cloned_vm_name=$(echo -n "pe-$PT_pe_version")
cloned_vmx_file=$(echo -n "$parent_dir/../$cloned_vm_name/$cloned_vm_name.vmx")
#echo "$cloned_vmx_file" 2>&1

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

# wait until the cloned VM's IP address is ready
counter=10
count_step=10
final_count=50
for (( ; ; ))
do 
  sleep $final_count
  ip=$(vmrun -T ws getGuestIPAddress "$cloned_vmx_file")
  if [ $? -eq 0 ]; then
    break # VM has IP address, exit the loop & task
  fi
  #echo "ip = $ip ret_val = $? counter = $counter" 2>&1
  ((counter + $count_step))
  if [ $counter -eq $final_count ]; then
    echo "Error: vmrun getGuestIPAddress command failed after waiting $final_count seconds, for VM to get assigned an IP address."
    exit 1
  fi
done

# return the IP address
cat <<-EOS
	{
				"ip": "$ip"
	}
EOS