guard 'rspec', :version => 2, :cli => '--color --format documentation' do
  watch(%r{^lib/puppet/(.*)/(.*)\.rb$}) {|m| puts m.inspect; "spec/unit/#{m[1]}/#{m[2]}_spec.rb"}
  watch(%r{^lib/puppet/(.*)/(.*)/.*\.rb$}) {|m| puts m.inspect; "spec/unit/#{m[1]}/#{m[2]}_spec.rb"}
  watch(%r{^spec/.*_spec\.rb$})
end
