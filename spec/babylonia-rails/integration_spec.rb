require 'spec_helper'

describe "Integration" do
  
  class BabylonianIntegratedField < ActiveRecord::Base
    self.table_name = 'babylonian_fields'
  end
  
  describe "Babylonia" do
    it "should already have extended active record" do
      expect(BabylonianIntegratedField).to be_respond_to(:build_babylonian_tower_on)
    end
  end
  
  
end