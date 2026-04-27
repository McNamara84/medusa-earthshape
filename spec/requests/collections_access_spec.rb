require "spec_helper"

describe "collections access", type: :request do
  let(:owner) { FactoryBot.create(:user_foo, administrator: false, password: "password", password_confirmation: "password") }
  let(:viewer) { FactoryBot.create(:user_baa, administrator: false, password: "password", password_confirmation: "password") }

  before do
    sign_in viewer
  end

  after do
    User.current = nil
  end

  let!(:readable_collection) do
    User.current = owner
    FactoryBot.create(:collection, name: "Readable Collection").tap do |collection|
      collection.record_property.update!(guest_readable: true, owner_readable: true, group_readable: false)
    end
  end

  let!(:private_collection) do
    User.current = owner
    FactoryBot.create(:collection, name: "Private Collection").tap do |collection|
      collection.record_property.update!(guest_readable: false, owner_readable: true, group_readable: false)
    end
  end

  it "filters unreadable records from the index" do
    get collections_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Readable Collection")
    expect(response.body).not_to include("Private Collection")
  end

  it "returns forbidden on show for unreadable records" do
    get collection_path(private_collection)

    expect(response).to have_http_status(:forbidden)
  end
end