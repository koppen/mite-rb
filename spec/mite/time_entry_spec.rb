require 'spec_helper'
require 'mite/time_entry'

describe Mite::TimeEntry do
  let(:time_entry) { subject }

  describe ".find_every" do
    context "when group_by is given" do
      let(:options) { {:params => {:group_by => "Stuff"}} }

      it "delegates to TimeEntryGroup" do
        Mite::TimeEntryGroup.should_receive(:find_every).with(options)
        Mite::TimeEntry.find_every(options)
      end
    end
  end

  describe "#customer" do
    context "project is given" do
      let(:project) { Mite::Project.new(:id => 42) }

      before :each do
        time_entry.project = project
      end

      it "returns customer from project" do
        project.stub(:customer).and_return('Customer instance')
        time_entry.customer.should === project.customer
      end
    end

    context "project is blank" do
      before :each do
        time_entry.project = nil
      end

      it "returns nil" do
        time_entry.customer.should be_nil
      end
    end
  end

  describe "#load" do
    let(:attributes) { {"minutes" => 37} }

    it "loads attributes from hash" do
      time_entry.load(attributes)
      time_entry.minutes.should == 37
    end

    context "tracking is given" do
      let(:attributes) { {"minutes" => 37, "tracking" => tracker } }
      let(:tracker) { Mite::Tracker.new }

      it "sets a new tracker" do
        Mite::Tracker.should_receive(:new).and_return(tracker)
        time_entry.load(attributes)
        time_entry.attributes["tracker"].should == tracker
      end
    end
  end

  describe "#project" do
    context "project_id is given" do
      before :each do
        time_entry.project_id = 42
      end

      it "gets project from the API" do
        Mite::Project.should_receive(:find).with(42)
        time_entry.project
      end
    end

    context "project_id is blank" do
      before :each do
        time_entry.project_id = nil
      end

      it "does not get project from the API" do
        Mite::Project.should_receive(:find).never
        time_entry.project
      end

      it "returns nil" do
        time_entry.project.should be_nil
      end
    end
  end

  describe "#service=" do
    let(:service) { Mite::Service.new(:id => 37) }

    it "sets the service_id" do
      time_entry.service = service
      time_entry.service_id.should == 37
    end

    it "sets customer_id to nil" do
      time_entry.service_id = 42
      time_entry.service = nil
      time_entry.service_id.should be_nil
    end
  end

  describe "#service" do
    context "service_id is given" do
      before :each do
        time_entry.service_id = 42
      end

      it "gets service from the API" do
        Mite::Service.should_receive(:find).with(42)
        time_entry.service
      end
    end

    context "service_id is blank" do
      before :each do
        time_entry.service_id = nil
      end

      it "does not get service from the API" do
        Mite::Service.should_receive(:find).never
        time_entry.service
      end

      it "returns nil" do
        time_entry.service.should be_nil
      end
    end
  end

  describe "#service=" do
    let(:service) { Mite::Service.new(:id => 37) }

    it "sets the service_id" do
      time_entry.service = service
      time_entry.service_id.should == 37
    end

    it "sets customer_id to nil" do
      time_entry.service_id = 42
      time_entry.service = nil
      time_entry.service_id.should be_nil
    end
  end

  describe "#start_tracker" do
    let(:tracker) { Mite::Tracker.new }

    it "starts tracking" do
      time_entry.id = 42
      Mite::Tracker.should_receive(:start).with(42).and_return(tracker)
      time_entry.start_tracker
      time_entry.tracker.should == tracker
    end
  end

  describe "#stop_tracker" do
    context "when tracking" do
      before :each do
        time_entry.attributes[:tracker] = 12
      end

      it "stops tracking" do
        Mite::Tracker.should_receive(:stop)
        time_entry.stop_tracker
      end
    end

    context "when not tracking" do
      before :each do
        time_entry.attributes[:tracker] = nil
      end

      it "doesn't stop tracking" do
        Mite::Tracker.should_receive(:stop).never
        time_entry.stop_tracker
      end
    end
  end

  describe "#tracking?" do
    context "when tracker is given" do
      before :each do
        time_entry.tracker = "Foo"
      end

      it "returns true" do
        time_entry.tracking?.should be_true
      end
    end

    context "when tracking is blank" do
      before :each do
        time_entry.tracker = nil
      end

      it "returns false" do
        time_entry.tracking?.should_not be_true
      end
    end
  end
end
