require 'spec_helper'

describe LanguagesValidator do
  
  class BabylonianField < ActiveRecord::Base
    
    build_babylonian_tower_on :marshes
    validates :marshes, languages: { present: [:de, :en, :it], length: 5..11 }
    
  end
  
  describe "validations" do
    subject { BabylonianField.new(marshes: "Hello") }
    before(:each) do
      I18n.stub locale: :en, available_locales: [:de, :en, :it]
    end
    context "presence validations" do
      context "when invalid" do
        it "should indicate which languages are not translated" do
          subject.should_not be_valid
          subject.errors[:marshes].first.should == "should be filled in DE and IT"
          subject.errors[:marshes_en].should be_empty
          subject.errors[:marshes_de].first.should == "should be filled"
          subject.errors[:marshes_it].first.should == "should be filled"
        end
        it "should indicate remaining incomplete languages if some are updated" do
          subject.marshes = {it: 'SOMETHING'}
          subject.should_not be_valid
          subject.errors[:marshes].first.should == "should be filled in DE"
          subject.errors[:marshes_en].should be_empty
          subject.errors[:marshes_it].should be_empty
          subject.errors[:marshes_de].first.should == "should be filled"
        end
        it "should work when attributes are deleted" do
          subject.marshes = ''
          subject.should_not be_valid
          subject.errors[:marshes].first.should == "should be filled in DE, EN, and IT"
          subject.errors[:marshes_en].first.should == "should be filled"
          subject.errors[:marshes_de].first.should == "should be filled"
          subject.errors[:marshes_it].first.should == "should be filled"
        end
      end
      context "when valid" do
        before(:each) do
          subject.marshes = {en: 'Hello', de: 'Hello', it: 'Hello'}
        end
        it "should be valid" do
          subject.should be_valid
        end
      end
    end
    context "length validations" do
      before(:each) do
        subject.marshes = {en: 'H', de: 'Hello', it: 'Hlo'}
      end
      context "when invalid" do
        it "should indicate that the languages that are not in length" do
          subject.should_not be_valid
          subject.errors[:marshes].first.should == "should be between 5 and 11 characters in EN and IT"
          subject.errors[:marshes_en].first.should == "should be between 5 and 11 characters"
          subject.errors[:marshes_it].first.should == "should be between 5 and 11 characters"
        end
      end
      context "when valid" do
        before(:each) do
          subject.marshes = {en: 'HelloHelloH', de: 'Hello', it: 'Hello'}
        end
        it "should be valid" do
          subject.should be_valid
        end
      end
    end
  end
  
  
end