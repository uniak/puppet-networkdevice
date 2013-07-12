require 'spec_helper'
require 'puppet/util/network_device/cisco_ios/device'

describe Puppet::Util::NetworkDevice::Cisco_ios::Device do
  before(:each) do
    @transport = stub_everything 'transport', :is_a? => true, :command => ''
    @cisco = Puppet::Util::NetworkDevice::Cisco_ios::Device.new('sshios://user:password@localhost:22/')
    @cisco.transport = @transport
  end

  describe 'when creating the device' do
    it 'should find the enable password from the url' do
      cisco = Puppet::Util::NetworkDevice::Cisco_ios::Device.new('sshios://user:password@localhost:22/?enable=enable_password')
      cisco.enable_password == 'enable_password'
    end

    it 'should prefer the enable password from the options' do
      cisco = Puppet::Util::NetworkDevice::Cisco_ios::Device.new('sshios://user:password@localhost:22/?enable=enable_password', :enable_password => 'mypass')
      cisco.enable_password == 'mypass'
    end

    it 'should find the crypt bool from the url' do
      File.stubs(:read).with('/etc/puppet/networkdevice-secret').returns('foobar')
      cisco = Puppet::Util::NetworkDevice::Cisco_ios::Device.new('sshios://96cc073a43df48098b6b4cae9366c677:7d211471517adf2821bd88ced8e8d378@localhost:22/?enable=enable_password&crypt=true')
      cisco.crypt == true
    end

    it 'should decrypt the provided user and password' do
      Puppet.stubs(:[]).with(:confdir).returns('/etc/puppet')
      File.stubs(:read).with('/etc/puppet/networkdevice-secret').returns('foobar')
      cisco = Puppet::Util::NetworkDevice::Cisco_ios::Device.new('sshios://96cc073a43df48098b6b4cae9366c677:7d211471517adf2821bd88ced8e8d378@localhost:22/?enable=enable_password&crypt=true')
      cisco.transport.user.should == 'user'
      cisco.transport.password.should == 'pass'
    end

  end

  describe "when connecting to the physical device" do
    it "should connect to the transport" do
      @transport.expects(:connect)
      @cisco.connect_transport
    end

    it "should attempt to login" do
      @cisco.expects(:login)
      @cisco.connect_transport
    end

    it "should tell the device to not page" do
      @transport.expects(:command).with("terminal length 0", :noop => false)
      @cisco.connect_transport
    end

    it "should enter the enable password if returned prompt is not privileged" do
      @transport.stubs(:command).yields("Switch>").returns("")
      @cisco.expects(:enable)
      @cisco.connect_transport
    end

    it "should create the switch object" do
      Puppet::Util::NetworkDevice::Cisco_ios::Model::Switch.expects(:new).with(@transport, {}).returns(stub_everything('switch'))
      # TODO: Convert it to Method calls
      # Dont't access IVars directly
      @facts = stub_everything 'facts'
      @facts.stubs(:facts_to_hash).returns({})
      @cisco.instance_variable_set(:@facts, @facts)
      @cisco.init_switch
    end

    describe "when login in" do
      it "should not login if transport handles login" do
        @transport.expects(:handles_login?).returns(true)
        @transport.expects(:command).never
        @transport.expects(:expect).never
        @cisco.login
      end

      it "should send username if one has been provided" do
        @transport.expects(:command).with("user", {:prompt => /^Password:/, :noop => false})
        @cisco.login
      end

      it "should send password after the username" do
        @transport.expects(:command).with("user", {:prompt => /^Password:/, :noop => false})
        @transport.expects(:command).with("password", :noop => false)
        @cisco.login
      end

      it "should expect the Password: prompt if no user was sent" do
        @cisco.url.user = ''
        @transport.expects(:expect).with(/^Password:/)
        @transport.expects(:command).with("password", :noop => false)
        @cisco.login
      end
    end

    describe "when entering enable password" do
      it "should raise an error if no enable password has been set" do
        @cisco.enable_password = nil
        lambda{ @cisco.enable }.should raise_error
      end

      it "should send the enable command and expect an enable prompt" do
        @cisco.enable_password = 'mypass'
        @transport.expects(:command).with("enable", {:prompt => /^Password:/, :noop => false})
        @cisco.enable
      end

      it "should send the enable password" do
        @cisco.enable_password = 'mypass'
        @transport.stubs(:command).with("enable", {:prompt => /^Password:/, :noop => false})
        @transport.expects(:command).with("mypass", :noop => false)
        @cisco.enable
      end
    end

    describe "when having parsed a configuration" do
      before do
	@data = <<END
!
interface FastEthernet2/0/1
 description foreman
 switchport access vlan 1105
 switchport mode access
 switchport nonegotiate
 switchport port-security
 switchport port-security aging time 1
 switchport port-security violation restrict
 switchport port-security aging type inactivity
 spanning-tree portfast
 spanning-tree bpduguard enable
 ip dhcp snooping limit rate 5
!
interface FastEthernet2/0/2
 description razor
 switchport access vlan 1105
 switchport mode access
 switchport nonegotiate
 switchport port-security
 switchport port-security aging time 1
 switchport port-security violation restrict
 switchport port-security aging type inactivity
 spanning-tree portfast
 spanning-tree bpduguard enable
 ip dhcp snooping limit rate 5
!
END
        @transport.stubs(:command).with("sh run", {:cache => true, :noop => false}).returns(@data)

	@vtp_status = <<END
VTP Version capable             : 1 to 3
VTP version running             : 3
VTP Domain Name                 : uniak-vz
VTP Pruning Mode                : Disabled
VTP Traps Generation            : Enabled
Device ID                       : 0015.2b14.0400

Feature VLAN:
--------------
VTP Operating Mode                : Client
Number of existing VLANs          : 6
Number of existing extended VLANs : 20
Configuration Revision            : 13
Primary ID                        : 9c4e.2024.1380
Primary Description               : vz-2k
MD5 digest                        : 0x57 0x72 0x17 0x6E 0xCD 0xB4 0x3D 0xE6 
                                    0xCF 0x7A 0xE3 0x99 0xAB 0x44 0xCF 0x57 


Feature MST:
--------------
VTP Operating Mode                : Transparent

          
Feature UNKNOWN:
--------------
VTP Operating Mode                : Transparent
END
        @transport.stubs(:command).with("sh vtp status", {:cache => true, :noop => false}).returns(@vtp_status)

        @facts = stub_everything 'facts'
        @facts.stubs(:facts_to_hash).returns({})
        @cisco.instance_variable_set(:@facts, @facts)
        @cisco.init_switch
      end

      it "should have interfaces" do
        @cisco.switch.params[:interfaces].value.should_not be_empty
      end

      it "should be able to lookup interfaces" do
        @cisco.switch.interface('FastEthernet2/0/2').should_not be_nil
      end
    end
  end
end
