require "spec_helper"

describe "record property access", type: :request do
  let(:owner) { FactoryBot.create(:user_foo, administrator: false, password: "password", password_confirmation: "password") }
  let(:viewer) { FactoryBot.create(:user_baa, administrator: false, password: "password", password_confirmation: "password") }

  after do
    User.current = nil
  end

  describe "GET /stones/:stone_id/record_property" do
    let!(:readable_stone) do
      User.current = owner
      FactoryBot.create(:stone, name: "Readable Stone").tap do |stone|
        stone.record_property.update!(guest_readable: true, owner_readable: true, group_readable: false)
      end
    end

    let!(:private_stone) do
      User.current = owner
      FactoryBot.create(:stone, name: "Private Stone").tap do |stone|
        stone.record_property.update!(guest_readable: false, owner_readable: true, group_readable: false)
      end
    end

    it "allows access to readable parent resources" do
      sign_in viewer

      get stone_record_property_path(readable_stone), headers: { "ACCEPT" => "application/json" }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["global_id"]).to eq(readable_stone.global_id)
    end

    it "returns forbidden for unreadable parent resources" do
      sign_in viewer

      get stone_record_property_path(private_stone), headers: { "ACCEPT" => "application/json" }

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "PATCH /stones/:stone_id/record_property" do
    let!(:managed_stone) do
      User.current = owner
      FactoryBot.create(:stone, name: "Managed Stone").tap do |stone|
        stone.record_property.update!(guest_readable: false, owner_readable: true, owner_writable: true, group_readable: false, group_writable: false)
      end
    end

    it "returns forbidden for non-writable parent resources" do
      sign_in viewer

      patch stone_record_property_path(managed_stone), params: {
        record_property: {
          guest_readable: true
        }
      }

      expect(response).to have_http_status(:forbidden)
      expect(managed_stone.record_property.reload.guest_readable).to eq(false)
    end

    it "allows the owner to update the record property" do
      sign_in owner

      patch stone_record_property_path(managed_stone), params: {
        record_property: {
          guest_readable: true
        }
      }

      expect(response).to have_http_status(:found)
      expect(managed_stone.record_property.reload.guest_readable).to eq(true)
    end
  end
end