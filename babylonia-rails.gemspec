# -*- encoding: utf-8 -*-
$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')
require 'babylonia/rails/version'

Gem::Specification.new do |s|
  s.name              = "babylonia-rails"
  s.version           = Babylonia::Rails::VERSION
  s.authors           = ["Beat Richartz"]
  s.description       = "Babylonia for rails lets your rails users translate their content into their languages without additional tables or columns in your tables"
  s.email             = "attr_accessor@gmail.com"
  s.licenses          = ["MIT"]
  s.require_paths     = ["lib"]
  s.summary           = "Let there be languages for your rails users!"
  
  s.files             = `git ls-files`.split("\n")
  s.test_files        = `git ls-files -- spec/*`.split("\n")
  s.require_paths     = ["lib"]
  
  active_record       = ENV["ACTIVE_RECORD_VERSION"] || ">= 3.2.0"
  
  s.add_dependency              "babylonia", ">= 0.0.2"
  s.add_dependency              "activerecord", active_record
  s.add_development_dependency  "bundler", ">= 1.0.0"
end

