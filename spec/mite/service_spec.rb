require 'spec_helper'
require 'mite/service'

describe Mite::Service do
  let(:service) { subject }

  it_behaves_like "resource with active and archived"

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
