require 'flay'

desc "Analyze for code duplication"
task :flay do
  threshold = 25
  flay = Flay.new({:fuzzy => false, :verbose => false, :mass => threshold})
  flay.process(*Flay.expand_dirs_to_files(['lib']))

  flay.report

  raise "#{flay.masses.size} chunks of code have a duplicate mass > #{threshold}" unless flay.masses.empty?
end
