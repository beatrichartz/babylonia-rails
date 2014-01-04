# -*- encoding : utf-8 -*-
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :test)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'babylonia/rails'

module HelperMethods
  def establish_ar_connection
    ActiveRecord::Base.configurations = YAML.load_file(File.expand_path('./support/database.yml', File.dirname(__FILE__)))
    ActiveRecord::Base.establish_connection(:test)
  end
end

require File.expand_path('./support/tables.rb', File.dirname(__FILE__))

RSpec.configure do |configuration|
  include HelperMethods
  configuration.before(:suite) do
    establish_ar_connection

    CreateTestTables.new.up
  end
  configuration.after(:suite) do
    establish_ar_connection
    
    CreateTestTables.new.down
  end
end
