# Cisco Networkdevice Module
Warning: this project is currently work in progress and may **** your network.

## Overview

The Cisco Networkdevice Module provides a common way to manage various configuration properties with Puppet and was initially based on the network_device utility provided by Puppet.

### Currently implented / tested Puppet Types

* cisco_aaa_group
* cisco_acl
* cisco_archive
* cisco_config
* cisco_exec
* cisco_interface
* cisco_line
* cisco_radius_server
* cisco_snmp_server_community
* cisco_snmp_server_host
* cisco_snmp_server
* cisco_user
* cisco_vlan

### Partially implented

* cisco_snmp_server_group
* cisco_snmp_server_trap
* cisco_snmp_server_user
* cisco_snmp_server_view


### Tested with the following Switchtypes

* WS-C4506-E
* WS-C3750-24TS WS-C3750-24PS WS-C3750G-24TS-1U WS-C3750G-24PS WS-C3750-24TS-S WS-C3750-24P WS-C3750-48TS WS-C3750G-24PS-S WS-C3750E-24PD
* WS-C3560-12PC-S
* WS-C2960G-48TC-L WS-C2960-24TC-L

### Tested with the following Software Versions

* IOS 12.2(55)SE5 12.2(55)SE6
* IOS-XE 15.0(1r)SG7

## Usage

device.conf

    [$switch_fqdn]
    type cisco_ios
    url sshios://$user:$pass@$switch_fqdn:$ssh_port/?$flags


For various Examples see [/examples](https://github.com/uniak/puppet-networkdevice/tree/master/examples)

Note: If you want to see the Communication with the Switch append --debug to the Puppet device Command

## Who ?

* Markus Burger markus.burger at uni-ak.ac.at
* Nicole Nagele nicole.nagele at uni-ak.ac.at
* David Schmitt david at dasz.at

## Code Status

[![Build Status](https://travis-ci.org/uniak/puppet-networkdevice.png?branch=master)](https://travis-ci.org/uniak/puppet-networkdevice) [![Code Climate](https://codeclimate.com/github/uniak/puppet-networkdevice.png)](https://codeclimate.com/github/uniak/puppet-networkdevice)
