require "spec_helper"

describe "stones access", type: :request do
  let(:owner) { FactoryBot.create(:user_foo, administrator: false, password: "password", password_confirmation: "password") }
  let(:viewer) { FactoryBot.create(:user_baa, administrator: false, password: "password", password_confirmation: "password") }

  describe "GET /stones" do
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

    after do
      User.current = nil
    end

    it "renders only readable stones for the current user" do
      User.current = nil
      sign_in viewer

      get stones_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Readable Stone")
      expect(response.body).not_to include("Private Stone")
    end
  end

  describe "GET /stones/:id" do
    let!(:private_stone) do
      User.current = owner
      FactoryBot.create(:stone, name: "Protected Stone").tap do |stone|
        stone.record_property.update!(guest_readable: false, owner_readable: true, group_readable: false)
      end
    end

    after do
      User.current = nil
    end

    it "returns forbidden for unreadable stones" do
      User.current = nil
      sign_in viewer

      get stone_path(private_stone)

      expect(response).to have_http_status(:forbidden)
    end
  end
end