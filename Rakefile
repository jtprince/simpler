require 'rubygems'
require 'rake'
require 'jeweler'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rcov/rcovtask'

Jeweler::Tasks.new do |gem|
  gem.name = "simpler"
  gem.summary = %Q{TODO: one-line summary of your gem}
  gem.description = %Q{TODO: longer description of your gem}
  gem.email = "jtprince@gmail.com"
  gem.homepage = "http://github.com/jtprince/simpler"
  gem.authors = ["John Prince"]
  gem.add_development_dependency "bacon", ">= 0"
  # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
end

Rake::TestTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.verbose = true
end

Rcov::RcovTask.new do |spec|
  spec.libs << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.verbose = true
end

task :default => :spec

Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "simpler #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
