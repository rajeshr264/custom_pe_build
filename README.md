# vmware_workstation_homebuild
Builds a homelab environment to practice Infra as code at home. We will be using Bolt, vmrun command with Vmware workstation 15 pro, Puppet Enterprise, Continous deployment for Puppet enterprise to manage the apps. 

# SW Configurations
1. Desktop Tower running Ubuntu 18 LTS
2. VMWare workstation 15 pro Linux (Desktop SW)
3. pfsense is acting as the router, DNS Resolver and DHCP server  
4. The base VMs, that will be cloned, are configured to have:
   - configured with Bridge networking i.e they will have IPs on the network. pfSense will be the DHCP server & register the DNS name & resolve all DNS queries.
   - addSSH pub key as part of ~/.ssh/authorized_keys, so that the clones can be accessed immediately.
   - shut off auto dhcp in ubuntu 18.04 server : you need to edit /etc/netplan/00-installer-config.yaml and make the 'dhcp4: true' to be "dhcp4: false'. Then after you bring up the clone, connect to it via vmrun, you change the hostname first then put the 'dhcp4: true' back again. reboot. 
   - auto dhcp is automatically off in /etc/sysconfig/network-scripts/ifcfg-ens33 on CentOS 8 server: ONBOOT=no. we change the hostname, then ONBOOT=yes then reboot. 

# Inventory.yaml

The inventory.yaml file makes working the Bolt a lot easier. We don't want to check it in as it has passwords. Use this sample and create it in _Boltdir/inventory.yaml_
`
---
groups:
  - name: vmware_ws
    targets: [] # This will be populated by the Bolt plan
    config:
      transport: ssh
      ssh:
        private-key: ~/.ssh/id_rsa
        user: rajesh
        sudo-password: foobar12
        host-key-check: false
        run-as: root
`
**Automation Available**
1.   
