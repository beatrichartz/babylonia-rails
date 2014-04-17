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
  s.extensions        = 'ext/mkrf_conf.rb'
  
  s.add_dependency              'babylonia',      '~> 0.2', '>= 0.2.1'
  s.add_dependency              'activerecord',   '>= 3.1'
  s.add_development_dependency  'bundler',        '~> 1.3'
  s.add_development_dependency  'appraisal',      '~> 0.5'
  s.add_development_dependency  'rspec',          '~> 2'
  s.add_development_dependency  'rspec-rails',    '~> 2'
  s.add_development_dependency  'yard',           '~> 0.8'
  
  if RUBY_ENGINE == 'jruby'
    s.add_development_dependency 'activerecord-jdbcmysql-adapter'
  else
    s.add_development_dependency 'mysql2'
  end
  
  if 'rbx' == RUBY_ENGINE
    s.add_development_dependency  'rubysl',         '~> 2.0'
    s.add_development_dependency  'rubysl-test-unit', '~> 2.0'
    s.add_development_dependency  'racc',         '~> 1.4'
  end
end

