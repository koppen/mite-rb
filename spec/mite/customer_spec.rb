require 'spec_helper'
require 'mite/customer'

describe Mite::Customer do
  let(:customer) { subject }

  it_behaves_like "resource with active and archived"

  describe "#projects" do
    it "gets the customers projects from the API" do
      customer.id = 42
      Mite::Project.should_receive(:find).with(
        :all,
        :params => {
          :customer_id => 42
        }
      )
      customer.projects
    end
  end

  describe "#time_entries" do
    it "gets time entries for the customer from the API" do
      customer.id = 42
      Mite::TimeEntry.should_receive(:find).with(
        :all,
        :params => {
          :customer_id => 42
        }
      )
      customer.time_entries
    end
  end
end
