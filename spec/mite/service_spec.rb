require 'spec_helper'
require 'mite/service'

describe Mite::Service do
  let(:service) { subject }

  describe ".active" do
    let(:options) { {:foo => "bar"} }

    it "finds all services from the API" do
      Mite::Service.should_receive(:find).with(:all, options)
      Mite::Service.active(options)
    end
  end

  describe ".archived" do
    let(:options) { {:foo => "bar"} }

    it "finds all archived services from the API" do
      Mite::Service.should_receive(:find).with(:all, {:foo => "bar", :from => :archived})
      Mite::Service.archived(options)
    end
  end

  describe "#time_entries" do
    it "gets time entries for the service from the API" do
      service.id = 42
      Mite::TimeEntry.should_receive(:find).with(
        :all,
        :params => {
          :service_id => 42
        }
      )
      service.time_entries
    end
  end
end
