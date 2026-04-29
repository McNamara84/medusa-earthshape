require 'spec_helper'

describe QrcodesController do
  let(:user) { FactoryBot.create(:user) }

  before { sign_in user }

  describe "GET show" do
    before { get :show, params: { id: "sample-qr" } }

    it { expect(response).to have_http_status(:success) }
    it { expect(response.media_type).to eq("image/png") }

    it "returns a png payload" do
      expect(response.body.bytes.first(8)).to eq([137, 80, 78, 71, 13, 10, 26, 10])
    end

    it "uses the requested id in the filename" do
      expect(response.headers["Content-Disposition"]).to include("sample-qr.png")
    end
  end
end