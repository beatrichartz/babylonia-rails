require 'spec_helper'

describe Babylonia::Rails::Validators::LocaleUniquenessValidator do
  let(:case_sensitive_validation_options) {
    {
      uniqueness: {
        locales: [:de, :en, :fr]
      }
    }
  }
  let(:case_insensitive_validation_options) {
    {
      uniqueness: {
        case_sensitive: false,
        locales: [:de, :en, :fr]
      }
    }
  }
  let(:scoped_validation_options) {
    {
      uniqueness: {
        scope: :some_value,
        case_sensitive: false,
        locales: [:de, :en, :fr]
      }
    }
  }
  
  class BabylonianUniqueField < ActiveRecord::Base
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
  
  class BabylonianUniqueSecondField < ActiveRecord::Base
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
  
  class BabylonianUniqueThirdField < ActiveRecord::Base
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
    I18n.stub available_locales: [:de, :en, :it, :pi, :fr, :er]
    # it is not allowed to access structures created by let in before(:all), but installing the validators on each run is also not
    # the way to go.
    BabylonianUniqueField.install_validations(case_insensitive_validation_options) unless BabylonianUniqueField.installed_validations
    BabylonianUniqueSecondField.install_validations(case_sensitive_validation_options) unless BabylonianUniqueSecondField.installed_validations
    BabylonianUniqueThirdField.install_validations(scoped_validation_options) unless BabylonianUniqueThirdField.installed_validations
  end
  
  describe "case insensitive uniqueness validation" do
    let(:attributes) { { marshes: {en: "Hello, I'm a string!", de: "Hallo,\nIch bin ein Faden!", fr: "Bonjour: Je suis un fil" } } }
    let(:duplicate_attributes) { { marshes: {en: "hello, I'm a string!", de: "Hallo,\nich bin ein faden!", fr: "Bonjour: je suis un fil" } } }
    context "with an existing record" do
      let!(:existing) { BabylonianUniqueField.create(attributes) }
      subject { BabylonianUniqueField.new(duplicate_attributes) }
      after(:each) do
        existing.destroy
      end
      it "should validate the records uniqueness" do
        expect(subject).not_to be_valid
        expect(subject.errors.full_messages).to eq(["Marshes de has already been taken", "Marshes en has already been taken", "Marshes fr has already been taken"])
      end
    end
    context "with no existing record" do
      subject { BabylonianUniqueField.new(duplicate_attributes) }
      it "should validate the records uniqueness" do
        expect(subject).to be_valid
      end
    end
  end
  
  describe "case sensitive uniqueness validation" do
    let(:attributes) { { marshes: {en: "Hello, I'm a string!", de: "Hallo,\nIch bin ein Faden!", fr: "Bonjour: Je suis un fil" } } }
    let(:other_case_attributes) { { marshes: {en: "hello, I'm a string!", de: "Hallo,\nich bin ein faden!", fr: "Bonjour: je suis un fil" } } }
    context "with an existing record" do
      let!(:existing) { BabylonianUniqueSecondField.create(attributes) }
      subject { BabylonianUniqueSecondField.new(attributes) }
      after(:each) do
        existing.destroy
      end
      it "should validate the records uniqueness" do
        expect(subject).not_to be_valid
        expect(subject.errors.full_messages).to eq(["Marshes de has already been taken", "Marshes en has already been taken", "Marshes fr has already been taken"])
      end
    end
    context "with an existing record with differently cased attributes" do
      let!(:existing) { BabylonianUniqueSecondField.create(attributes) }
      subject { BabylonianUniqueSecondField.new(other_case_attributes) }
      after(:each) do
        existing.destroy
      end
      it "should validate the records uniqueness" do
        expect(subject).to be_valid
      end
    end
    context "with no existing record" do
      subject { BabylonianUniqueSecondField.new(attributes) }
      it "should validate the records uniqueness" do
        expect(subject).to be_valid
      end
    end
  end
  
  describe "scoped uniqueness validation" do
    let(:attributes) { { marshes: {en: "Hello, I'm a string!", de: "Hallo,\nIch bin ein Faden!", fr: "Bonjour: Je suis un fil" }, some_value: true } }
    let(:same_scope_attributes) { { marshes: {en: "hello, I'm a string!", de: "Hallo,\nich bin ein faden!", fr: "Bonjour: je suis un fil" }, some_value: true } }
    let(:other_scope_attributes) { { marshes: {en: "hello, I'm a string!", de: "Hallo,\nich bin ein faden!", fr: "Bonjour: je suis un fil" }, some_value: false } }
    context "with an existing record" do
      let!(:existing) { BabylonianUniqueThirdField.create(attributes) }
      subject { BabylonianUniqueThirdField.new(same_scope_attributes) }
      after(:each) do
        existing.destroy
      end
      it "should validate the records uniqueness" do
        expect(subject).not_to be_valid
        expect(subject.errors.full_messages).to eq(["Marshes de has already been taken", "Marshes en has already been taken", "Marshes fr has already been taken"])
      end
    end
    context "with an existing record in another scope" do
      let!(:existing) { BabylonianUniqueThirdField.create(attributes) }
      subject { BabylonianUniqueThirdField.new(other_scope_attributes) }
      after(:each) do
        existing.destroy
      end
      it "should validate the records uniqueness" do
        expect(subject).to be_valid
      end
    end
    context "with no existing record" do
      subject { BabylonianUniqueThirdField.new(attributes) }
      it "should validate the records uniqueness" do
        expect(subject).to be_valid
      end
    end
  end
  
end