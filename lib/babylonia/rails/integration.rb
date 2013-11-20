require 'babylonia'
require 'active_record'

ActiveRecord::Base.send(:extend, Babylonia::ClassMethods)
ActiveRecord::Base.send(:include, Babylonia::Rails::Validators)