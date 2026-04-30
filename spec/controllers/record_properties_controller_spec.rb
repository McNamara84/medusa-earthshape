require 'spec_helper'

describe RecordPropertiesController do
  let(:user) { FactoryBot.create(:user, administrator: false, username: "viewer", email: "viewer@example.com") }
  let(:other_user) { FactoryBot.create(:user_foo, administrator: false) }

  before do
    sign_in user
    User.current = user
  end

  after do
    User.current = nil
  end

  describe "GET show" do
    let(:stone) { FactoryBot.create(:stone, name: "recorded_stone") }

    before { get :show, params: { parent_resource: "stone", stone_id: stone.id }, format: :json }

    it "assigns the parent resource" do
      expect(assigns(:parent_resource)).to eq(stone)
    end

    it "renders the nested record property" do
      body = JSON.parse(response.body)

      expect(body["datum_id"]).to eq(stone.id)
      expect(body["datum_type"]).to eq("Stone")
      expect(body["global_id"]).to eq(stone.record_property.global_id)
    end
  end

  describe "GET show without permission" do
    let(:stone) do
      FactoryBot.create(:stone, name: "private_stone").tap do |record|
        record.record_property.update!(
          user_id: other_user.id,
          guest_readable: false,
          guest_writable: false,
          group_readable: false,
          group_writable: false,
          owner_readable: true,
          owner_writable: true
        )
      end
    end

    before { get :show, params: { parent_resource: "stone", stone_id: stone.id }, format: :json }

    it { expect(response).to have_http_status(:forbidden) }
  end

  describe "PUT update" do
    let(:stone) { FactoryBot.create(:stone, name: "editable_stone") }
    let(:attributes) { { guest_readable: true, guest_writable: true } }

    before do
      request.env["HTTP_REFERER"] = "/stones/#{stone.id}"
      put :update, params: { parent_resource: "stone", stone_id: stone.id, record_property: attributes }
    end

    it "updates the nested record property" do
      expect(assigns(:record_property).guest_readable).to be(true)
      expect(assigns(:record_property).guest_writable).to be(true)
    end

    it "redirects back to the referer" do
      expect(response).to redirect_to("/stones/#{stone.id}")
    end

    it "does not allow re-pointing the record property to a different datum" do
      other_stone = FactoryBot.create(:stone, name: "other_editable_stone")

      request.env["HTTP_REFERER"] = "/stones/#{stone.id}"
      put :update, params: {
        parent_resource: "stone",
        stone_id: stone.id,
        record_property: attributes.merge(datum_id: other_stone.id, datum_type: "Stone")
      }

      record_property = assigns(:record_property).reload
      expect(record_property.datum).to eq(stone)
      expect(record_property.datum_id).to eq(stone.id)
      expect(record_property.datum_type).to eq("Stone")
    end
  end
end