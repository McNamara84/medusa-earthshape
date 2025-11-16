require 'rails_helper'

RSpec.describe 'Debug Controller', type: :controller do
  controller(ApplicationController) do
    def index
      render plain: 'ok'
    end
  end

  before(:each) do
    puts '[DEBUG] Before block started'
    @routes = ActionDispatch::Routing::RouteSet.new
    @routes.draw { get 'index' => 'anonymous#index' }
    puts '[DEBUG] Routes drawn'
  end

  describe 'GET index' do
    it 'returns ok' do
      puts '[DEBUG] Test started'
      get :index
      puts '[DEBUG] Request completed'
      expect(response.body).to eq('ok')
      puts '[DEBUG] Test finished'
    end
  end
end
