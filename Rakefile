require 'rubygems'
require 'rake'
require 'jeweler'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rcov/rcovtask'

Jeweler::Tasks.new do |gem|
  gem.name = "simpler"
  gem.summary = %Q{simpler ("simple R")- A low-tech method to run R scripts.  Allows you to basically copy and paste R code and run it.}
  gem.description = %Q{you should check out rsruby first.  This is a very low-tech way to run R.  It does have the advantage of being able to run R code essentially unchanged.}
  gem.email = "jtprince@gmail.com"
  gem.homepage = "http://github.com/jtprince/simpler"
  gem.authors = ["John Prince"]
  gem.add_development_dependency "spec/more", ">= 0"
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
