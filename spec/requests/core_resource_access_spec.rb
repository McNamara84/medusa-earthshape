require "spec_helper"

describe "core resource access", type: :request do
  let(:owner) { FactoryBot.create(:user_foo, administrator: false, password: "password", password_confirmation: "password") }
  let(:viewer) { FactoryBot.create(:user_baa, administrator: false, password: "password", password_confirmation: "password") }

  before do
    sign_in viewer
  end

  after do
    User.current = nil
  end

  shared_examples "readable resource access" do |factory_name, collection_helper, member_helper, readable_name, private_name|
    let!(:readable_resource) do
      User.current = owner
      FactoryBot.create(factory_name, name: readable_name).tap do |resource|
        resource.record_property.update!(guest_readable: true, owner_readable: true, group_readable: false)
      end
    end

    let!(:private_resource) do
      User.current = owner
      FactoryBot.create(factory_name, name: private_name).tap do |resource|
        resource.record_property.update!(guest_readable: false, owner_readable: true, group_readable: false)
      end
    end

    it "filters unreadable records from the index" do
      get(public_send(collection_helper))

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(readable_name)
      expect(response.body).not_to include(private_name)
    end

    it "returns forbidden on show for unreadable records" do
      get(public_send(member_helper, private_resource))

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "boxes" do
    include_examples "readable resource access", :box, :boxes_path, :box_path, "Readable Box", "Private Box"
  end

  describe "places" do
    include_examples "readable resource access", :place, :places_path, :place_path, "Readable Place", "Private Place"
  end

  describe "analyses" do
    include_examples "readable resource access", :analysis, :analyses_path, :analysis_path, "Readable Analysis", "Private Analysis"
  end

  describe "bibs" do
    include_examples "readable resource access", :bib, :bibs_path, :bib_path, "Readable Bib", "Private Bib"
  end

  describe "attachment files" do
    include_examples "readable resource access", :attachment_file, :attachment_files_path, :attachment_file_path, "Readable Attachment", "Private Attachment"
  end
end