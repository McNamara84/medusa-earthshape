require "spec_helper"

describe SolrHelper::Solr do
  let(:resource) { instance_double(RestClient::Resource, post: "ok") }

  before do
    allow(RestClient::Resource).to receive(:new).and_return(resource)
  end

  describe "constants" do
    it "exposes the configured endpoint constant" do
      expect(described_class::ENDPOINT).to eq(
        "http://doidb.wdc-terra.org/igsnaasearch/admin/dataimport?command=full-import&clean=false&commit=true&optimize=false&wt=json&indent=true"
      )
    end
  end

  describe "#initialize" do
    it "uses the default endpoint when none is provided" do
      described_class.new(user: "alice", password: "secret")

      expect(RestClient::Resource).to have_received(:new).with(described_class::ENDPOINT, "alice", "secret")
    end

    it "uses a custom endpoint when one is provided" do
      described_class.new(user: "alice", password: "secret", endpoint: "https://solr.example.test")

      expect(RestClient::Resource).to have_received(:new).with("https://solr.example.test", "alice", "secret")
    end
  end

  describe "#deltaupdate" do
    it "posts an empty body to the configured endpoint" do
      client = described_class.new(endpoint: "https://solr.example.test")

      expect(resource).to receive(:post).with("")

      client.deltaupdate
    end
  end

  describe "#update" do
    it "posts an empty body to the configured endpoint" do
      client = described_class.new(endpoint: "https://solr.example.test")

      expect(resource).to receive(:post).with("")

      client.update
    end
  end
end