# @summary Entry point for installing and configuration of Puppet enterprise 

plan install_pe::provision (
  String $base_os_vmx_file,
  String $pe_version,
  Optional[String]  $r10k_remote = undef,
  Optional[String]  $r10k_private_key_file = undef,
)
{
  $localhost = get_targets('localhost')

  # Use vmrun to create a new VM for hosting PE
  $pe_changed_ver_string=regsubst($pe_version,'\.','_','G')
  $pe_host_ip = run_task('install_pe::clone_create_vm',$localhost, 
                          base_os_vmx_file => $base_os_vmx_file, pe_version => $pe_changed_ver_string).first['ip']
  #out::message("IP = $pe_host_ip")

  # Turn PE host IP into Bolt targets, and add to inventory
  $targets = Target.new("${$pe_host_ip}").add_to_group('vmware_ws')

  # set the Host name of PE-master and reboot  
  run_command("hostnamectl set-hostname pe${pe_changed_ver_string}",$targets,_run_as => 'root','_catch_errors'=>true)
  run_command("sed -i 's/ubuntu18/pe${pe_changed_ver_string}/' /etc/hosts",$targets,_run_as => 'root','_catch_errors'=>true)
  run_task("reboot",$targets) # 

  # install PE on the PE-host


}
