
shared_examples_for "newhostlistprop" do
  it "should allow a string with a single IP" do
    described_class.new(:name => name, prop => "192.168.0.1")
  end

  it "should allow an empty array" do
    described_class.new(:name => name, prop => [])
  end

  it "should allow an array with a single IP" do
    described_class.new(:name => name, prop => [ '192.168.0.1' ])
  end

  it "should allow an array with multiple IPs" do
    described_class.new(:name => name, prop => [ '192.168.0.1', '192.168.0.2' ])
  end

  it "should raise an exception if anything other then an IP is supplied" do
    expect { described_class.new(:name => name, prop => "foo.bar") }.to raise_error
  end
end

shared_examples_for "ensureable" do
  it "should allow :present" do
    described_class.new(:name => name, prop => :present)
  end

  it "should allow :absent" do
    described_class.new(:name => name, prop => :absent)
  end

  it "should raise an exception on everyhting else" do
    expect { described_class.new(:name => name, prop => "foobar") }.to raise_error
  end
end
