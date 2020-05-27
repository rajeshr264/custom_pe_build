# @summary Entry point for installing and configuration of Puppet enterprise 

plan install_pe::provision (
  String $base_os_vmx_file,
  String $pe_version,
  Optional[String]  $r10k_remote = undef,
  Optional[String]  $r10k_private_key_file = undef, 
)
{
  $localhost = get_targets('localhost')

  # Use vmrun to create a new VM for hosting PE. remove the '.' chars in the version, say "2019.7.0" to "201970".
  # Can't replace the '.' chars with '-' as puppet func didn't like it. 
  #can't replace '.' with '_' as its illegal hostname for Centos8's NetworkManager. 
  $pe_changed_ver_string=regsubst($pe_version,'\.','','G')
   # set the Host name of PE-master 
  $pe_fqdns = "pe${pe_changed_ver_string}.harshamlabs.tk"
 
  run_task('install_pe::clone_create_vm',$localhost, 
           base_os_vmx_file => $base_os_vmx_file, pe_fqdns => "${pe_fqdns}")
  
  # Turn PE host IP into Bolt targets, and add to inventory
  $target = Target.new("${$pe_fqdns}").add_to_group('vmware_ws')

  # open the firewall for HTTP, HTTPS and install python2 as it is a requirement for peadm::read_file task.
  run_command("firewall-cmd --zone=public --add-service=http",$target, '_run_as' => 'root')
  run_command("firewall-cmd --zone=public --add-service=https", $target, '_run_as' => 'root')
  run_command("yum install -y python2", $target,'_run_as' => 'root' )

  # install PE on the PE-host
  $install_result = run_plan("peadm::provision", master_host => "$pe_fqdns", 
  console_password => "puppetlabs", version=>"2019.7.0")

}
