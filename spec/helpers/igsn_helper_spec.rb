require "spec_helper"

describe IgsnHelper::Igsn do
  let(:resource) { instance_double(RestClient::Resource) }
  let(:nested_resource) { instance_double(RestClient::Resource) }

  before do
    allow(RestClient::Resource).to receive(:new).and_return(resource)
    allow(resource).to receive(:[]).and_return(nested_resource)
    allow(nested_resource).to receive(:get).and_return("ok")
    allow(nested_resource).to receive(:post).and_return("ok")
  end

  describe "constants" do
    it "exposes the configured endpoint constant" do
      expect(described_class::ENDPOINT).to eq("https://doidb.wdc-terra.org/igsnaa")
    end
  end

  describe "#initialize" do
    it "builds a rest client resource from the provided credentials" do
      described_class.new(user: "alice", password: "secret", endpoint: "https://igsn.example.test")

      expect(RestClient::Resource).to have_received(:new).with("https://igsn.example.test", "alice", "secret")
    end
  end

  describe "#resolve" do
    it "fetches the IGSN record" do
      client = described_class.new(endpoint: "https://igsn.example.test")

      expect(resource).to receive(:[]).with("igsn/10273/GFABC1234").and_return(nested_resource)
      expect(nested_resource).to receive(:get)

      client.resolve("GFABC1234")
    end
  end

  describe "#mint" do
    it "posts a plain-text mint payload" do
      client = described_class.new(endpoint: "https://igsn.example.test")

      expect(resource).to receive(:[]).with("igsn").and_return(nested_resource)
      expect(nested_resource).to receive(:post).with(
        "igsn=10273/GFABC1234\nurl=https://example.test/stones/1",
        content_type: "text/plain;charset=UTF-8"
      )

      client.mint("GFABC1234", "https://example.test/stones/1")
    end
  end

  describe "#upload_regmetadata" do
    it "posts registration metadata as xml" do
      client = described_class.new(endpoint: "https://igsn.example.test")

      expect(resource).to receive(:[]).with("metadata").and_return(nested_resource)
      expect(nested_resource).to receive(:post).with("<xml />", content_type: "application/xml;charset=UTF-8")

      client.upload_regmetadata("<xml />")
    end
  end

  describe "#upload_metadata" do
    it "posts metadata for a specific igsn" do
      client = described_class.new(endpoint: "https://igsn.example.test")

      expect(resource).to receive(:[]).with("igsnmetadata/10273/GFABC1234").and_return(nested_resource)
      expect(nested_resource).to receive(:post).with("<xml />", content_type: "application/xml;charset=UTF-8")

      client.upload_metadata("GFABC1234", "<xml />")
    end
  end

  describe "#metadata" do
    it "fetches stored metadata for a specific igsn" do
      client = described_class.new(endpoint: "https://igsn.example.test")

      expect(resource).to receive(:[]).with("metadata/10273/GFABC1234").and_return(nested_resource)
      expect(nested_resource).to receive(:get)

      client.metadata("GFABC1234")
    end
  end
end