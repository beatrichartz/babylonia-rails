require 'spec_helper'

describe LocalesValidator do
  
  class BabylonianPersistentField < ActiveRecord::Base
    self.table_name = 'babylonian_fields'
    
    build_babylonian_tower_on :marshes
    validates :marshes, locales: { presence: [:de, :en, :it], length: {in: 5..11} }
    
  end
  
  describe "persistence" do
    before(:each) do
      I18n.stub available_locales: [:de, :en, :it]
    end
    subject { BabylonianPersistentField.new(marshes: {en: 'Hello', de: 'Hello', it: 'Hello'})}
    it "should be possible to store the string value" do
      subject.save!
      subject.reload
      subject.marshes_hash.should == {en: 'Hello', de: 'Hello', it: 'Hello'}
    end
  end
  
end