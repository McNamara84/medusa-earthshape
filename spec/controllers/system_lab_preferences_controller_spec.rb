require 'spec_helper'

describe SystemLabPreferencesController do
  let(:user) { FactoryBot.create(:user) }

  before { sign_in user }

  describe "GET show" do
    before { get :show }

    it { expect(response).to have_http_status(:success) }
    it { expect(response).to render_template("show") }
  end
end