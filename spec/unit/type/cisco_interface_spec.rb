#! /usr/bin/env ruby
require 'spec_helper'

describe Puppet::Type.type(:cisco_interface) do

  let(:name) { 'FastEthernet2/0/1' }

  it "should have a 'name' parameter'" do
    described_class.new(:name => name)[:name].should == name
  end

  it "should be applied on device" do
    described_class.new(:name => name).must be_appliable_to_device
  end

  [:name].each do |p|
    it "should have a #{p} param" do
      described_class.attrtype(p).should == :param
    end
  end

  [:description, :mode, :access, :trunk_allowed_vlan,
   :trunk_encapsulation, :trunk_native_vlan, :negotiate,
   :port_security, :port_security_mac_address,
   :port_security_aging_time, :port_security_aging_type,
   :spanning_tree, :spanning_tree_guard, :spanning_tree_cost,
   :spanning_tree_port_priority, :dhcp_snooping_limit_rate
  ].each do |p|
  it "should have a #{p} property" do
      described_class.attrtype(p).should == :property
    end
  end

  describe "when validating attribute values" do
    before do
      @provider = stub 'provider', :class => described_class.defaultprovider, :clear => nil
      described_class.defaultprovider.stubs(:new).returns(@provider)
    end

    describe "name" do
      it "should allow FastEthernet interfaces" do
        described_class.new(:name => 'FastEthernet2/0/1')
      end

      it "should raise an exception on everything else" do
        expect { described_class.new(:name => "foobar") }.to raise_error
      end
    end

    describe "description" do
      it "should allow any valid string" do
        described_class.new(:name => name, :description => 'foo-bar')
      end

      it "should raise an exception on strings containing newlines" do
        expect { described_class.new(:name => name, :description => "foo\nbar") }.to raise_error
      end
    end

    describe "mode" do
      [ [:access,  {:access => 20}],
        [:dot1q,   {}],
        [:dynamic, {}],
        [:private, {}],
        [:trunk,   {:trunk_allowed_vlan => '1-100',
                    :trunk_encapsulation => :dot1q,
                    :trunk_native_vlan => '1'}]
      ].each do |mode, args|
        it "should allow #{mode}" do
          args[:name] = name
          args[:mode] = mode
          described_class.new(args)
        end
      end

      it "should raise an exception on everything else" do
        expect { described_class.new(:mode => "foobar") }.to raise_error
      end

      describe "when mode is access" do
        let(:mode) { :access }

        [ [20, "a number"],
          ["20", "a string representing a number"],
          [:dynamic, "dynamic"]
        ].each do |value,desc|
          it "should allow setting 'access' to #{desc}: #{value.inspect}" do
            described_class.new(:name => name, :mode => mode, :access => value)
          end
        end

        [ [:absent, "muhblah"] ].each do |value|
          it "should not allow setting 'access' to :absent" do
            expect { described_class.new(:name => name, :mode => mode, :access => value) }.to raise_error
          end
        end

        [ [:trunk_allowed_vlans, "1"],
          [:trunk_encapsulation, :dot1q],
          [:trunk_native_vlan, '1'],
        ].each do |prop,val|
          it "should not allow setting #{prop}" do
            expect { described_class.new(:name => name, :mode => mode, prop => val) }.to raise_error
          end
        end
      end

      describe "when mode is trunk" do
        let(:mode) { :trunk }

        [ ["1", "a single number"],
          [10, "a single number"],
          ["10-20", "a single range"],
          ["1,5", "a list of numbers"],
          ["1,5,10", "a list of numbers"],
          ["1,5,10,20,30,40,50,1000", "a list of numbers"],
          ["1-10,12,15", "a list of numbers and ranges"],
          ["1,10-12,15", "a list of numbers and ranges"],
          ["1,10,12-15", "a list of numbers and ranges"],
        ].each do |value, desc|
          it "should allow setting allowed vlans to #{desc}: #{value.inspect}" do
            described_class.new(:name => name, :mode => mode, :trunk_allowed_vlan => value, :trunk_encapsulation => :dot1q, :trunk_native_vlan => 1)
          end
        end

        [ "muhblah", "1-", "1,-", "-", "," ].each do |value|
          it "should not allow setting allowed vlans to #{value.inspect}" do
            expect { described_class.new(:name => name, :mode => mode, :trunk_allowed_vlan => value, :trunk_encapsulation => :dot1q, :trunk_native_vlan => 1) }.to raise_error
          end
        end

        [ :dot1q, :isl, :negotiate ].each do |encaps|
          it "should allow setting the encapsulation to #{encaps.inspect}" do
            described_class.new(:name => name, :mode => mode, :trunk_allowed_vlan => "1", :trunk_encapsulation => encaps, :trunk_native_vlan => 1)
          end
        end

        [ :absent, "muhblah" ].each do |value|
          it "should not allow setting the encapsulation to #{value.inspect}" do
            expect { described_class.new(:name => name, :mode => mode, :trunk_allowed_vlan => "1", :trunk_encapsulation => value, :trunk_native_vlan => 1) }.to raise_error
          end
        end

        [ "10", 20 ].each do |value|
          it "should allow setting the native vlan to #{value.inspect}" do
            described_class.new(:name => name, :mode => mode, :trunk_allowed_vlan => "1", :trunk_encapsulation => :dot1q, :trunk_native_vlan => value)
          end
        end

        [ "muhblah" ].each do |value|
          it "should not allow setting the native vlan to #{value.inspect}" do
            expect { described_class.new(:name => name, :mode => mode, :trunk_allowed_vlan => "1", :trunk_encapsulation => :dot1q, :trunk_native_vlan => value) }.to raise_error
          end
        end
      end
    end

    describe "negotiate" do
      [true,false, "true", "false"].each do |value|
        it "should accept #{value.inspect}" do
          described_class.new(:name => name, :negotiate => value)
        end
      end

      [0, 1, 2, 3, :absent, "muh"].each do |value|
        it "should not accept #{value.inspect}" do
          expect { described_class.new(:name => name, :negotiate => value) }.to raise_error
        end
      end
    end

    describe "port security" do
      [ :protect, :restrict, :shutdown, :shutdown_vlan ].each do |port_security|
        it "should accept #{port_security.inspect}" do
   described_class.new(:name => name, :port_security => port_security, :port_security_mac_address => :sticky, :port_security_aging_time => 1, :port_security_aging_type => :absolute)
        end

        describe "when port security is set to #{port_security.inspect}" do

          [ [:port_security_mac_address, [:sticky, "0a:00:27:00:00:00", "0a:00:27:00:00:00".upcase], ["1234567890", "12:34:56:78:90:ab:cd", "ab:cd", "", "11:22:33:44:55", "Foo"]],
            [:port_security_aging_time,  ["1", 1, 10, 123], [-1, "-10", "foo"]],
            [:port_security_aging_type,  [:absolute, :inactivity], ["foo"]],
          ].each do |prop, valid, invalid|
            describe prop do
              valid.each do |value|
                it "should accept #{value.inspect}" do
                  args = {
                    :name                      => name,
                    :port_security             => port_security,
                    :port_security_mac_address => :sticky,
                    :port_security_aging_time  => 1,
                    :port_security_aging_type  => :absolute,
                  }
                  args[prop] = value
                  described_class.new(args)
                end
              end
              invalid.each do |value|
                it "should not accept #{value.inspect}" do
                  args = {
                    :name                      => name,
                    :port_security             => port_security,
                    :port_security_mac_address => :sticky,
                    :port_security_aging_time  => 1,
                    :port_security_aging_type  => :absolute,
                  }
                  args[prop] = value
                  expect { described_class.new(args) }.to raise_error
                end
              end
            end
          end
        end
      end

      describe "when port security is disabled" do
        let(:port_security) { :absent }

        [ [:port_security_mac_address, :sticky],
          [:port_security_aging_time, 1],
          [:port_security_aging_type, :inactivity],
        ].each do |prop, value|
          describe prop do
            it "should accept absent" do
              described_class.new(:name => name, :port_security => port_security, prop => :absent)
            end

            it "should not accept a value" do
              expect { described_class.new(:name => name, :port_security => port_security, prop => value) }.to raise_error
            end
          end
        end
      end
    end

    describe :spanning_tree do
      [:leaf, :node].each do |value|
        it "should accept #{value.inspect}" do
          described_class.new(:name => name, :spanning_tree => value)
        end
      end

      [:absent, "foo"].each do |value|
        it "should not accept #{value.inspect}" do
          expect { described_class.new(:name => name, :spanning_tree => value) }.to raise_error
        end
      end

      describe "when set to :leaf" do
        let(:spanning_tree) { :leaf }

        describe :spanning_tree_guard do
          [:root, :absent, :loop].each do |value|
            it "should accept #{value.inspect}" do
              described_class.new(:name => name, :spanning_tree => spanning_tree, :spanning_tree_guard => value)
            end
          end

          ["foo"].each do |value|
            it "should not accept #{value.inspect}" do
              expect { described_class.new(:name => name, :spanning_tree => spanning_tree, :spanning_tree_guard => value) }.to raise_error
            end
          end
        end

        describe :spanning_tree_cost do
          [:absent].each do |value|
            it "should accept #{value.inspect}" do
              described_class.new(:name => name, :spanning_tree => spanning_tree, :spanning_tree_cost => value)
            end
          end

          [-1, 1, 16, 32, 160, 240, 300].each do |value|
            it "should not accept #{value.inspect}" do
              expect { described_class.new(:name => name, :spanning_tree => spanning_tree, :spanning_tree_cost => value) }.to raise_error
            end
          end
        end

        describe :spanning_tree_port_priority do
          [:absent].each do |value|
            it "should accept #{value.inspect}" do
              described_class.new(:name => name, :spanning_tree => spanning_tree, :spanning_tree_port_priority => value)
            end
          end

          [-1, 1, 16, 32, 160, 240, 300].each do |value|
            it "should not accept #{value.inspect}" do
              expect { described_class.new(:name => name, :spanning_tree => spanning_tree, :spanning_tree_port_priority => value) }.to raise_error
            end
          end
        end
      end

      describe "when set to node" do
        let(:spanning_tree) { :node }

        describe :spanning_tree_guard do
          [:absent, :loop].each do |value|
            it "should accept #{value.inspect}" do
              described_class.new(:name => name, :spanning_tree => spanning_tree, :spanning_tree_guard => value)
            end
          end

          [:root, "foo"].each do |value|
            it "should not accept #{value.inspect}" do
              expect { described_class.new(:name => name, :spanning_tree => spanning_tree, :spanning_tree_guard => value) }.to raise_error
            end
          end
        end

        describe :spanning_tree_cost do
          [:absent, 1, 16, 32, 160, 240, 300].each do |value|
            it "should accept #{value.inspect}" do
              described_class.new(:name => name, :spanning_tree => spanning_tree, :spanning_tree_cost => value)
            end
          end

          [-1].each do |value|
            it "should not accept #{value.inspect}" do
              expect { described_class.new(:name => name, :spanning_tree => spanning_tree, :spanning_tree_cost => value) }.to raise_error
            end
          end
        end

        describe :spanning_tree_port_priority do
          [:absent, 0, 16, 32, 160, 240].each do |value|
            it "should accept #{value.inspect}" do
              described_class.new(:name => name, :spanning_tree => spanning_tree, :spanning_tree_port_priority => value)
            end
          end

          [-1, 1, 300].each do |value|
            it "should not accept #{value.inspect}" do
              expect { described_class.new(:name => name, :spanning_tree => spanning_tree, :spanning_tree_port_priority => value) }.to raise_error
            end
          end
        end
      end
    end
    describe :spanning_tree_bpduguard do
      [:present, :absent].each do |value|
        it "should accept #{value.inspect}" do
          described_class.new(:name => name, :spanning_tree_bpduguard => value)
        end
      end

      it "should not accept anything else" do
        expect { described_class.new(:name => name, :spanning_tree_bpduguard => 'foobar') }.to raise_error
      end
    end
    describe :dhcp_snooping_limit_rate do
      [:absent, 1, 5, 10].each do |value|
        it "should accept #{value.inspect}" do
          described_class.new(:name => name, :dhcp_snooping_limit_rate => value)
        end
      end

      [-1, 0, "foo"].each do |value|
        it "should not accept #{value.inspect}" do
          expect { described_class.new(:name => name, :dhcp_snooping_limit_rate => value) }.to raise_error
        end
      end
    end
  end
end
