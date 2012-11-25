require 'spec_helper'

describe Mite::Project do
  before :all do
    Mite.account = 'test'
  end

  describe ".all" do
    let(:response) { {:projects => [
      :project => {:id => 42}
    ]}.to_json }

    it "finds projects from the API" do
      api_stub(:get, "projects.json", response)
      projects = Mite::Project.all
    end

    it "returns array of projects" do
      api_stub(:get, "projects.json", response)
      projects = Mite::Project.all
      projects.first.should be_a(Mite::Project)
    end

    it "finds projects whose name containing 'web'" do
      api_stub(:get, "projects.json?name=web", response)
      projects = Mite::Project.all(:params => {:name => 'web'})
    end
  end

  describe ".archived" do
    let(:response) { {:projects => [
      :project => {:id => 42}
    ]}.to_json }

    it "finds archived projects from the API" do
      api_stub(:get, "projects/archived.json", response)
      projects = Mite::Project.archived
    end

    it "returns array of projects" do
      api_stub(:get, "projects/archived.json", response)
      projects = Mite::Project.archived
      projects.first.should be_a(Mite::Project)
    end
  end

  describe ".find" do
    let(:response) { {:project => {:id => 42} }.to_json }

    it "finds project with specific id" do
      api_stub(:get, "projects/42.json", response)
      projects = Mite::Project.find(42)
      projects.should be_a(Mite::Project)
    end
  end

  describe "#customer" do
    let(:project) {
      Mite::Project.new(:customer_id => 42)
    }

    context "customer_id is given" do
      it "gets the customer from the API" do
        Mite::Customer.should_receive(:find).with(42)
        project.customer
      end
    end

    context "customer_id is blank" do
      before :each do
        project.customer_id = nil
      end

      it "does not get the customer from the API" do
        Mite::Customer.should_receive(:find).never
        project.customer
      end

      it "returns nil" do
        project.customer.should be_nil
      end
    end
  end

  describe "#customer=" do
    let(:customer) { Mite::Customer.new(:id => 37) }
    let(:project) { Mite::Project.new(:customer_id => 42) }

    it "sets the customer_id" do
      project.customer = customer
      project.customer_id.should == 37
    end

    it "sets customer_id to nil" do
      project.customer_id = 42
      project.customer = nil
      project.customer_id.should be_nil
    end
  end

  describe "#name_with_customer" do
    let(:project) { Mite::Project.new(:name => "Take over the entire tri-state area") }

    context "when customer_name is nil" do
      it "returns name" do
        project.name_with_customer.should == project.name
      end
    end

    context "when customer_name is set" do
      before :each do
        project.customer_name = "Dr. Doofenshmirtz"
      end

      it "returns name with customer name" do
        project.name_with_customer.should == "Take over the entire tri-state area (Dr. Doofenshmirtz)"
      end
    end
  end

  describe "#time_entries" do
    let(:project) { Mite::Project.new(:id => 42) }

    it "gets all time entries of a project" do
      Mite::TimeEntry.should_receive(:find).with(:all, {:params => {:project_id => 42}})
      project.time_entries
    end

    it "passes options on to TimeEntry finder" do
      Mite::TimeEntry.should_receive(:find).with(:all, {:params => {:project_id => 42, :locked => true}})
      project.time_entries(:locked => true)
    end
  end
end
