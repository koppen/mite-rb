shared_examples "resource with active and archived" do
  describe ".active" do
    let(:options) { {:foo => "bar"} }

    it "finds all records from the API" do
      subject.class.should_receive(:find).with(:all, options)
      subject.class.active(options)
    end
  end

  describe ".archived" do
    let(:options) { {:foo => "bar"} }

    it "finds all archived records from the API" do
      subject.class.should_receive(:find).with(:all, {:foo => "bar", :from => :archived})
      subject.class.archived(options)
    end
  end
end
