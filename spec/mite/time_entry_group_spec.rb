require 'spec_helper'
require 'mite/time_entry'

describe Mite::TimeEntryGroup do
  let(:time_entry_group) { subject }

  describe ".find_every" do
    context "when group_by is not given" do
      let(:options) { {:params => {:not_grouped_by => "Stuff"}} }

      it "returns all TimeEntries" do
        time_entries = ["TimeEntry"]
        Mite::TimeEntry.should_receive(:all).and_return(time_entries)
        Mite::TimeEntryGroup.find_every(options).should == time_entries
      end
    end

    context "when group_by is given" do
      let(:options) { {:params => {:group_by => "user"}} }
      let(:response) {
        [{
          "time_entry_group" => {
            "minutes" => 280,
            "time_entries_params" => {
              "user_id" => "23"
            },
            "revenue" => 25.66,
            "user_id" => 23,
            "user_name" => "Jakob",
            "from" => "2010-02-24",
            "to" => "2012-11-28"
          }
        }].to_json
      }

      it "returns grouped TimeEntries" do
        api_stub(:get, "/time_entries.json?group_by=user", response)
        results = Mite::TimeEntryGroup.find_every(options)
        results.first.should be_instance_of(Mite::TimeEntryGroup)
      end

      it "moves time_entries_params from attributes" do
        api_stub(:get, "/time_entries.json?group_by=user", response)
        results = Mite::TimeEntryGroup.find_every(options)
        time_entry_group = results.first
        time_entry_group.attributes[:time_entry_params].should be_nil
        time_entry_group.time_entries_params.should == {"user_id" => "23"}
      end
    end
  end

  describe "#time_entries" do
    let(:response) { {:time_entries => [{
      :time_entry => {:minutes => 37}
    }]}.to_json }

    context "when time_entries_params is given" do
      before :each do
        time_entry_group.time_entries_params = {"user_id" => "23"}
      end

      it "fetches time entries from API" do
        api_stub(:get, "time_entries.json?user_id=23", response)
        time_entry_in_group = time_entry_group.time_entries.first
        time_entry_in_group.minutes.should == 37
      end

      context "when options are given" do
        it "merges distinct time_entry_params into options params" do
          api_stub(:get, "time_entries.json?user_id=23&locked=true", response)
          time_entry_group.time_entries(:params => {"locked" => "true"}).should_not be_empty
        end

        it "returns empty array if the values are conflicting" do
          time_entry_group.time_entries(:params => {"user_id" => "42"}).should be_empty
        end
      end
    end

    context "when time_entries_params is blank" do
      before :each do
        time_entry_group.time_entries_params = nil
      end

      it "returns empty array" do
        time_entry_group.time_entries.should be_empty
      end
    end
  end

end
