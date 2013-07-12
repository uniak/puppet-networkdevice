# Cisco Networkdevice Module
Warning: this project is currently work in progress and may **** your network.

## Overview

The Cisco Networkdevice Module provides a common way to manage various configuration properties with Puppet and was initially based on the network_device utility provided by Puppet.

Currently most providers, types, etc are suffixed with _ios as to avoid collusion with the network_device code already provided by puppet.

### Currently implented / tested Puppet Types

* cisco_config
* cisco_user
* cisco_aaa_group
* cisco_radius_server
* cisco_snmp_server_community_ios
* cisco_snmp_server_ios
* cisco_snmp_server_host_ios
* cisco_line
* cisco_acl
* cisco_archive
* interface_ios
* cisco_exec

### Tested with the following Switchtypes

* WS-C4506-E
* WS-C3750-24TS WS-C3750-24PS WS-C3750G-24TS-1U WS-C3750G-24PS WS-C3750-24TS-S WS-C3750-24P WS-C3750-48TS WS-C3750G-24PS-S WS-C3750E-24PD
* WS-C3560-12PC-S
* WS-C2960G-48TC-L WS-C2960-24TC-L

### Tested with the following Software Versions

* IOS 12.2(55)SE5 12.2(55)SE6
* IOS-XE 15.0(1r)SG7

## Installation and Usage

Example device.conf

    [$switch_fqdn]
    type cisco_ios
    url sshios://$user:$pass@$switch_fqdn:$ssh_port/?$flags

Exmaple Manifest

    cisco_config {
      'running:'
        ip_domain_name              => 'exmaple.com',
        logging_trap                => 'critical',
        loggin_facility             => 'local0',
        logging_servers             => [ '10.10.10.10' ],
        ip_name_servers             => [ '10.10.10.10' ],
        ntp_servers                 => [ '10.10.10.10' ],
        clock_timezone              => 'MET 1 0',
        ip_domain_lookup            => absent,
        vtp_version                 => 3,
        vtp_password                => 'foo',
        password_encryption         => present,
        ip_dhcp_snooping            => present,
        ip_dhcp_snooping_vlans      => '1-99',
        ip_dhcp_snooping_remote_id  => hostname,
        ip_dhcp_relay_information   => trust-all,
        aaa_new_model               => present,
        ip_ssh                      => present,
        ip_ssh_version              => 2,
        errdisable_recovery_cause   => [ 'link-flap' ]
    }

    cisco_user {
      'foo':
        privilege     => 15,
        password_type => 7,
        password      => '$password_hash'
    }

    cisco_aaa_group {
      'foo':
        ensure                => present,
        protocol              => 'radius',
        server                => '10.10.10.10',
        auth_port             => 1812,
        acct_port             => 1813,
        local_authentication  => true,
        local_authorization   => true
    }

    cisco_radius_server {
      '10.10.10.10':
        ensure    => present,
        auth_port => 1812,
        acct_port => 1813,
        key_type  => 7,
        key       => '$password_hash'
    }

    cisco_snmp_server_community_ios {
      'foo':
        ensure  => present,
        perm    => ro,
        acl     => 'SNMP-ALLOW'
    }

    cisco_snmp_server_ios {
      'running':
        contact       => 'foo@bar',
        enable_traps  => [ 'vtp', 'port-security' ]
    }

    cisco_snmp_server_host_ios {
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
        write_memory  => present,
        time_period   => 30
    }

    interface_ios {
      'FastEthernet1/0/1':
        description               => 'foobar',
        mode                      => 'access',
        spanning_tree             => 'leaf',
        dhcp_snooping_limit_rate  => '5',
        negotiate                 => false,
        port_security             => 'restrict',
        port_security_mac_address => absent,
        port_security_aging_time  => 1,
        port_security_aging_type  => 'inactivity';
      'FastEthernet1/0/2':
        description               => 'foobar uplink',
        mode                      => 'trunk',
        trunk_encapsulation       => 'dot1q',
        spanning_tree             => 'node',
        dhcp_snooping_trust       => present,
        negotiate                 => true;
    }

    cisco_exec {
      'write':
        command     => 'write',
        context     => 'exec',
        refreshonly => true
    }


Invocation

    /usr/bin/puppet device --verbose --ignorecache --no-usecacheonfailure --noop

Note: If you want to see the Communication with the Switch append --debug

## Who ?

* Markus Burger <markus.burger@uni-ak.ac.at>
* Nicole Nagele <nicole.nagele@uni-ak.ac.at>
* David Schmitt <david@dasz.at>
