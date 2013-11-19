require 'spec_helper'

describe "Integration" do
  
  class BabylonianField < ActiveRecord::Base
    
  end
  
  describe "Babylonia" do
    it "should already have extended active record" do
      BabylonianField.should be_respond_to(:build_babylonian_tower_on)
    end
  end
  
  
end