cisco_config {
  'running:'
    aaa_new_model                     => present,
    clock_timezone                    => 'MET 1 0',
    enable_secret                     => '$secret',
    errdisable_recovery_cause         => [ 'link-flap' ],
    errdisable_recovery_interval      => 60,
    hostname                          => 'switch-1'
    ip_default_gateway                => '10.10.10.1',
    ip_dhcp_relay_information         => 'trust-all',
    ip_dhcp_snooping                  => present,
    ip_dhcp_snooping_remote_id        => 'hostname',
    ip_dhcp_snooping_vlans            => '1-99',
    ip_domain_lookup                  => absent,
    ip_domain_lookup_source_interface => 'Vlan1',
    ip_domain_name                    => 'example.com',
    ip_name_servers                   => [ '10.10.10.10' ],
    ip_radius_source_interface        => 'Vlan1',
    ip_ssh                            => present,
    ip_ssh_version                    => 2,
    loggin_facility                   => 'local0',
    logging_servers                   => [ '10.10.10.10' ],
    logging_trap                      => 'critical',
    ntp_servers                       => [ '10.10.10.10' ],
    password_encryption               => present,
    system_mtu_routing                => 1500,
    vtp_domain                        => 'backbone.example.com',
    vtp_operation_mode                => 'client',
    vtp_password                      => 'foo',
    vtp_version                       => 3
}

cisco_user {
  'foo':
    password      => '$password_hash',
    password_type => 7,
    privilege     => 15
}

cisco_aaa_group {
  'foo':
    ensure                => present,
    acct_port             => 1813,
    auth_port             => 1812,
    local_authentication  => true,
    local_authorization   => true,
    protocol              => 'radius',
    server                => '10.10.10.10'
}

cisco_radius_server {
  '10.10.10.10':
    ensure    => present,
    acct_port => 1813,
    auth_port => 1812,
    key       => '$password_hash',
    key_type  => 7
}

cisco_snmp_server_community {
  'foo':
    ensure  => present,
    acl     => 'SNMP-ALLOW',
    perm    => 'ro'
}

cisco_snmp_server {
  'running':
    contact       => 'foo@bar',
    enable_traps  => [ 'vtp', 'port-security' ]
}

cisco_snmp_server_host {
  '10.10.10.10':
    ensure    => present,
    community => 'foo'
}

cisco_line {
  'vty 0':
    access_class  => 'SSH-ALLOW in',
    exec_timeout  => 3600,
    logging       => 'synchronous',
    transport     => 'ssh'
}

cisco_acl {
  'SSH-ALLOW':
    acl => [ 'permit 10.10.10.10' ]
}

cisco_archive {
  'running':
    path          => 'tftp://10.10.10.10/foo.bar',
    time_period   => '30',
    write_memory  => present
}

cisco_interface {
  'FastEthernet1/0/1':
    access                    => '99',
    description               => 'foobar',
    dhcp_snooping_limit_rate  => '5',
    mode                      => 'access',
    negotiate                 => false,
    port_security             => 'restrict',
    port_security_aging_time  => '1',
    port_security_aging_type  => 'inactivity',
    port_security_mac_address => absent,
    spanning_tree             => 'leaf';
  'FastEthernet1/0/2':
    description                 => 'uplink',
    dhcp_snooping_trust         => present,
    mode                        => 'trunk',
    negotiate                   => true,
    spanning_tree               => 'node',
    spanning_tree_cost          => '10',
    spanning_tree_guard         => 'loop',
    spanning_tree_port_priority => '16',
    trunk_encapsulation         => 'dot1q';
  'FastEthernet1/0/3':
    description               => 'access point',
    dhcp_snooping_limit_rate  => '5',
    mode                      => 'trunk',
    negotiate                 => false,
    spanning_tree             => 'node',
    trunk_allowed_vlan        => '1-99'
    trunk_encapsulation       => 'dot1q',
    trunk_native_vlan         => '99';
}

cisco_exec {
  'write config':
    command     => 'write',
    context     => 'exec',
    refreshonly => true
}
