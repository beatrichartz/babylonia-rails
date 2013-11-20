require 'spec_helper'

describe Babylonia::Rails::Validators::LocalesValidator do
  let(:format_validation_options) {
    {
      with: /\A\z/,
      locales: [:de, :en, :it]
    }
  }
  let(:numericality_validation_options) {
    {
      only_integer: true,
      locales: [:de, :en, :it]
    }
  }
  let(:inclusion_validation_options) {
    {
      in: %w(small medium large),
      locales: [:de, :en, :it]
    }
  }
  let(:exclusion_validation_options) {
    {
      in: %w(big huge),
      locales: [:de, :en, :it]
    }
  }
  let(:length_validation_options) {
    {
      in: 5..11,
      locales: [:de, :en, :it]
    }
  }
  let(:validation_options) {
    {
      presence: [:de, :en, :it],
      absence: [:pi, :gb, :er],
      format: format_validation_options,
      numericality: numericality_validation_options,
      inclusion: inclusion_validation_options,
      exclusion: exclusion_validation_options,
      length: length_validation_options
    }
  }
  
  class BabylonianField < ActiveRecord::Base

    build_babylonian_tower_on :marshes

    class << self
      attr_accessor :installed_validations
      def install_validations(options)
        self.installed_validations = true
        validates :marshes, locales: options
      end
    end

  end
  
  class BabylonianSecondField < ActiveRecord::Base
    self.table_name = 'babylonian_fields'
    
    build_babylonian_tower_on :marshes

    class << self
      attr_accessor :installed_validations
      def install_validations(options)
        self.installed_validations = true
        validates :marshes, locales: options
      end
    end
  end
  
  class BabylonianThirdField < ActiveRecord::Base
    self.table_name = 'babylonian_fields'
    
    build_babylonian_tower_on :marshes

    class << self
      attr_accessor :installed_validations
      def install_validations(options)
        self.installed_validations = true
        validates :marshes, allow_nil: true, locales: options
      end
    end
  end
  
  before(:each) do
    I18n.stub available_locales: [:de, :en, :it, :pi, :gb, :er]
    # it is not allowed to access structures created by let in before(:all), but installing the validators on each run is also not
    # the way to go.
    BabylonianField.install_validations(validation_options) unless BabylonianField.installed_validations
    BabylonianSecondField.install_validations(validation_options) unless BabylonianSecondField.installed_validations
    BabylonianThirdField.install_validations(validation_options) unless BabylonianThirdField.installed_validations
  end
  
  describe "rails validations except confirmation, acceptance and uniqueness" do
    subject { BabylonianField.new }
    let(:format_validator) { double('format_validator') }
    let(:inclusion_validator) { double('inclusion_validator') }
    let(:exclusion_validator) { double('exlusion_validator') }
    let(:length_validator) { double('length_validator') }
    let(:presence_validator) { double('presence_validator') }
    let(:absence_validator) { double('absence_validator') }
    let(:numericality_validator) { double('absence_validator') }
    
    it "should pass them on to the rails validators" do
      [:format, :inclusion, :exclusion, :length, :numericality].each do |validator|
        options = send(:"#{validator}_validation_options")
        attributes = options[:locales].map{|l| :"marshes_#{l}"}
        "ActiveModel::Validations::#{validator.to_s.classify}Validator".constantize.should_receive(:new).with(options.dup.delete_if{|k,v| k == :locales}.merge(attributes: attributes)).and_return(send(:"#{validator}_validator"))
        send(:"#{validator}_validator").should_receive(:validate).with(subject)
      end
      ActiveModel::Validations::PresenceValidator.should_receive(:new).with(attributes: [:marshes_de,:marshes_en,:marshes_it]).and_return(presence_validator)
      presence_validator.should_receive(:validate).with(subject)
      ActiveModel::Validations::AbsenceValidator.should_receive(:new).with(attributes: [:marshes_pi,:marshes_gb,:marshes_er]).and_return(absence_validator)
      absence_validator.should_receive(:validate).with(subject)
      subject.valid? #=> this will be true since all calls are mocked
    end
    context "integration" do
      context "with defaults" do
        subject { BabylonianSecondField.new }
        it "should work for all kinds of errors" do
          subject.should_not be_valid
          [:de, :en, :it].each do |lang|
            subject.errors[:"marshes_#{lang}"].should == ["is not included in the list", "is too short (minimum is 5 characters)", "is not a number", "can't be blank"]
          end
        end
      end
      context "with allow_nil set to true" do
        subject { BabylonianThirdField.new }
        it "should allow blank" do
          subject.should be_valid
          subject.errors.should be_blank
        end
      end
    end

  end
  
  
end