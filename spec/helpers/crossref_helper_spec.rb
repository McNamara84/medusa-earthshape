require "spec_helper"

describe CrossrefHelper::Metadata do
  let(:valid_xml) do
    <<~XML
      <doi_records>
        <doi_record>
          <crossref>
            <journal>
              <journal_metadata>
                <full_title>Journal of Testing</full_title>
                <abbrev_title>J Test</abbrev_title>
                <issn>1234-5678</issn>
              </journal_metadata>
              <journal_issue>
                <publication_date>
                  <year>2024</year>
                  <month>09</month>
                </publication_date>
                <journal_volume>
                  <volume>12</volume>
                </journal_volume>
                <issue>3</issue>
              </journal_issue>
              <journal_article>
                <titles>
                  <title>Example Title</title>
                </titles>
                <contributors>
                  <person_name contributor_role="author">
                    <given_name>Ada</given_name>
                    <surname>Lovelace</surname>
                  </person_name>
                  <person_name contributor_role="author">
                    <given_name>Grace</given_name>
                    <surname>Hopper</surname>
                  </person_name>
                </contributors>
                <pages>
                  <first_page>10</first_page>
                  <last_page>20</last_page>
                </pages>
                <doi_data>
                  <resource>https://example.test/articles/1</resource>
                </doi_data>
              </journal_article>
            </journal>
          </crossref>
        </doi_record>
      </doi_records>
    XML
  end
  let(:error_xml) { "<error>not found</error>" }
  let(:document) { Nokogiri::XML(valid_xml) }

  describe "#initialize" do
    let(:raw_doi) { "10.1000/ example\n123" }

    before do
      allow_any_instance_of(described_class).to receive(:get_xml).and_return(document)
    end

    it "sanitizes the DOI and builds the request URL" do
      metadata = described_class.new(doi: raw_doi, pid: "contact@example.test")

      expect(metadata.instance_variable_get(:@doi)).to eq("10.1000/example123")
      expect(metadata.url).to eq(
        "https://crossref.org/openurl/?noredirect=true&format=unixref&pid=contact@example.test&id=doi:10.1000/example123"
      )
      expect(metadata.xml).to eq(document)
    end
  end

  describe "#doi" do
    before do
      allow_any_instance_of(described_class).to receive(:get_xml).and_return(document)
      stub_const("Crossref", Module.new)
      stub_const("Crossref::Metadata", class_double("Crossref::Metadata").as_stubbed_const)
    end

    it "delegates to the crossref client metadata class" do
      metadata = described_class.new(pid: "contact@example.test", base_url: "https://crossref.example/openurl?format=unixref")

      expect(Crossref::Metadata).to receive(:new).with(
        doi: "10.1000/test",
        pid: "contact@example.test",
        url: "https://crossref.example/openurl?format=unixref&pid=contact@example.test"
      )

      metadata.doi("10.1000/test")
    end
  end

  describe "metadata parsing" do
    subject(:metadata) do
      described_class.new(doi: "10.1000/example", pid: "contact@example.test")
    end

    before do
      allow_any_instance_of(described_class).to receive(:get_xml).and_return(document)
    end

    it "detects a successful response" do
      expect(metadata.result?).to be(true)
    end

    it "returns the article title" do
      expect(metadata.title).to eq("Example Title")
    end

    it "returns the authors as hashes" do
      expect(metadata.authors).to eq(
        [
          { given_name: "Ada", surname: "Lovelace" },
          { given_name: "Grace", surname: "Hopper" }
        ]
      )
    end

    it "returns the publication date" do
      expect(metadata.published).to eq(year: "2024", month: "09")
    end

    it "returns journal metadata and pagination" do
      expect(metadata.journal).to include(
        full_title: "Journal of Testing",
        abbrev_title: "J Test",
        issn: "1234-5678",
        volume: "12",
        issue: "3",
        first_page: "10",
        last_page: "20"
      )
    end

    it "returns the resource URL" do
      expect(metadata.resource).to eq("https://example.test/articles/1")
    end

    it "returns nil for a missing xpath node" do
      expect(metadata.xpath_first("missing/node")).to be_nil
    end

    it "finds matching nodes via xpath_ns" do
      expect(metadata.xpath_ns("contributors/person_name").size).to eq(2)
    end
  end

  describe "error handling" do
    it "returns false when xml is missing" do
      metadata = described_class.new
      allow(metadata).to receive(:xml).and_return(nil)

      expect(metadata.result?).to be(false)
    end

    it "returns false when an error node is present" do
      allow_any_instance_of(described_class).to receive(:get_xml).and_return(Nokogiri::XML(error_xml))
      metadata = described_class.new(doi: "10.1000/example")

      expect(metadata.result?).to be(false)
    end
  end

  describe "private helpers" do
    subject(:metadata) { described_class.new }

    it "removes whitespace from a doi" do
      expect(metadata.send(:sanitize_doi, " 10.1000/ab c\n123 ")).to eq("10.1000/abc123")
    end

    it "hashifies child nodes and ignores newline-only content" do
      nodes = Nokogiri::XML("<person><given_name>Ada</given_name><surname>Lovelace</surname></person>").root.children

      expect(metadata.send(:hashify_nodes, nodes)).to eq(given_name: "Ada", surname: "Lovelace")
    end
  end
end