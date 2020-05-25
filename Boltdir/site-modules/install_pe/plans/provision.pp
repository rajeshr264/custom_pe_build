# @summary Entry point for installing and configuration of Puppet enterprise 

plan install_pe::provision (
  String $base_os_vmx_file,
  String $pe_version,
)
{
  $localhost = get_targets('localhost')

  notice("#{Target}")
  $pe_host_ip = run_task('install_pe::clone_create_vm',$localhost, 
                      base_os_vmx_file => $base_os_vmx_file, pe_version => $pe_version).first['ip']


  out::message("IP = $pe_host_ip")

  #run_task($pe_version, $pe_host)
}
