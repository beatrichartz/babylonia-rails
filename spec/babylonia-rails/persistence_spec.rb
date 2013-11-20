require 'spec_helper'

describe LanguagesValidator do
  
  class BabylonianField < ActiveRecord::Base
    
    build_babylonian_tower_on :marshes
    validates :marshes, languages: { present: [:de, :en, :it], length: 5..11 }
    
  end
  
  describe "persistence" do
    before(:each) do
      I18n.stub available_locales: [:de, :en, :it]
    end
    subject { BabylonianField.new(marshes: {en: 'Hello', de: 'Hello', it: 'Hello'})}
    it "should be possible to store the string value" do
      subject.save!
      subject.reload
      subject.marshes_hash.should == {en: 'Hello', de: 'Hello', it: 'Hello'}
    end
  end
  
end