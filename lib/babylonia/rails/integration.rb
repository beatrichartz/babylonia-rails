require 'babylonia'
require 'active_record'

ActiveRecord::Base.send(:extend, Babylonia::ClassMethods)