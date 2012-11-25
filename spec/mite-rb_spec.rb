require 'spec_helper'
require 'mite-rb'

describe Mite do
  describe ".authenticate" do
    after(:each) do
      # Reset authentication details to prevent them from spilling into other tests
      Mite.authenticate(nil, nil)
    end

    it "stores username" do
      Mite.authenticate('rick@techno-weenie.net', 'spacemonkey')
      Mite.instance_variable_get(:@user).should == 'rick@techno-weenie.net'
    end

    it "stores password" do
      Mite.authenticate('rick@techno-weenie.net', 'spacemonkey')
      Mite.password.should == 'spacemonkey'
    end

    it "returns true" do
      Mite.authenticate('rick@techno-weenie.net', 'spacemonkey').should be_true
    end
  end

  describe "validate" do
    context "when connection is valid" do
      before :each do
        Mite.stub(:validate!).and_return(true)
      end

      it "returns true" do
        Mite.validate.should be_true
      end
    end

    context "when connection is not valid" do
      before :each do
        Mite.stub(:validate!).and_raise(RuntimeError)
      end

      it "returns false" do
        Mite.validate.should be_false
      end
    end
  end

  describe "validate!" do
    context "when connection is valid" do
      before :each do
        Mite::Account.stub(:find).and_return('something')
      end

      it "returns true" do
        Mite.validate!.should be_true
      end
    end

    context "when connection is not valid" do
      let(:exception) { RuntimeError }

      before :each do
        Mite::Account.stub(:find).and_raise(exception)
      end

      it "raises an exception with further details" do
        lambda do
          Mite.validate!
        end.should raise_error(exception)
      end
    end
  end
end
