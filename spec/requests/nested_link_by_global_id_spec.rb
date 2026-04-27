require "spec_helper"

describe "nested link by global id", type: :request do
  let(:owner) { FactoryBot.create(:user_foo, administrator: false, password: "password", password_confirmation: "password") }

  before do
    sign_in owner
  end

  after do
    User.current = nil
  end

  describe "POST /stones/:stone_id/analyses/link_by_global_id" do
    let!(:stone) do
      User.current = owner
      FactoryBot.create(:stone, name: "Link Parent Stone")
    end

    let!(:analysis) do
      User.current = owner
      FactoryBot.create(:analysis, name: "Link Target Analysis")
    end

    it "links an existing analysis to the parent stone" do
      post "/stones/#{stone.id}/analyses/link_by_global_id",
           params: { global_id: analysis.global_id },
           headers: { "HTTP_REFERER" => stone_path(stone) }

      expect(response).to redirect_to(stone_path(stone))
      expect(stone.analyses.reload).to include(analysis)
    end
  end

  describe "POST /stones/:stone_id/attachment_files/link_by_global_id" do
    let!(:stone) do
      User.current = owner
      FactoryBot.create(:stone, name: "Attachment Parent Stone")
    end

    let!(:attachment_file) do
      User.current = owner
      FactoryBot.create(:attachment_file, :with_real_file)
    end

    let!(:filetopic) { FactoryBot.create(:filetopic, name: "Updated Topic") }

    it "links an existing attachment file and updates the filetopic" do
      post "/stones/#{stone.id}/attachment_files/link_by_global_id",
           params: { global_id: attachment_file.global_id, filetopic_id: filetopic.id },
           headers: { "HTTP_REFERER" => stone_path(stone) }

      expect(response).to redirect_to(stone_path(stone))
      expect(stone.attachment_files.reload).to include(attachment_file)
      expect(attachment_file.reload.filetopic).to eq(filetopic)
    end
  end
end