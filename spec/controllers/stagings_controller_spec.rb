require 'spec_helper'

describe StagingsController do
  let(:user) { FactoryBot.create(:user) }
  let(:safe_referer) { '/stagings' }
  let(:staging_id) { '1' }

  before do
    sign_in user
    request.env['HTTP_REFERER'] = safe_referer
  end

  shared_examples 'safe ingest redirect' do |action_name:, nested_key:, model_class:, valid_attributes:, invalid_template:|
    let(:resource) { instance_double(model_class.name, save!: true) }

    before do
      allow(model_class).to receive(:new).and_return(resource)
    end

    it 'redirects to the safe referer on success' do
      post action_name, params: { id: staging_id, staging: { nested_key => valid_attributes } }

      expect(response).to redirect_to(safe_referer)
    end

    it 'falls back to root for a path-relative referer' do
      request.env['HTTP_REFERER'] = 'where_i_came_from'

      post action_name, params: { id: staging_id, staging: { nested_key => valid_attributes } }

      expect(response).to redirect_to('/')
    end

    it 'renders the invalid template when persistence raises' do
      allow(model_class).to receive(:new).and_raise(StandardError)

      post action_name, params: { id: staging_id, staging: { nested_key => valid_attributes } }

      expect(response).to render_template(invalid_template)
    end
  end

  include_examples 'safe ingest redirect',
    action_name: :ingest_box,
    nested_key: :box_create_attributes,
    model_class: Box,
    valid_attributes: { name: 'Imported box', box_type_id: '1' },
    invalid_template: 'box_invalid'

  include_examples 'safe ingest redirect',
    action_name: :ingest_place,
    nested_key: :place_create_attributes,
    model_class: Place,
    valid_attributes: { name: 'Imported place', latitude: '1', longitude: '1' },
    invalid_template: 'place_invalid'

  include_examples 'safe ingest redirect',
    action_name: :ingest_collection,
    nested_key: :collection_create_attributes,
    model_class: Collection,
    valid_attributes: { name: 'Imported collection' },
    invalid_template: 'collection_invalid'

  include_examples 'safe ingest redirect',
    action_name: :ingest_stone,
    nested_key: :stone_create_attributes,
    model_class: Stone,
    valid_attributes: { name: 'Imported stone' },
    invalid_template: 'stone_invalid'

  describe 'POST ingest_box with tab param' do
    let(:resource) { instance_double(Box.name, save!: true) }

    before do
      request.env['HTTP_REFERER'] = '/stagings?tab=old&view=import'
      allow(Box).to receive(:new).and_return(resource)

      post :ingest_box, params: {
        id: staging_id,
        tab: 'boxes',
        staging: { box_create_attributes: { name: 'Imported box', box_type_id: '1' } }
      }
    end

    it 'preserves the requested tab in the redirect' do
      expect(response).to redirect_to('/stagings?view=import&tab=boxes')
    end
  end

  describe 'POST ingest_box updating an existing box with tab param' do
    let(:resource) { instance_double(Box.name, update!: true) }

    before do
      request.env['HTTP_REFERER'] = '/stagings?view=import&tab=old'
      allow(Box).to receive(:find).with('42').and_return(resource)

      post :ingest_box, params: {
        id: staging_id,
        tab: 'boxes',
        staging: { box_create_attributes: { id: '42', name: 'Imported box', box_type_id: '1' } }
      }
    end

    it 'replaces the existing tab in the redirect after update' do
      expect(response).to redirect_to('/stagings?view=import&tab=boxes')
    end
  end

  describe 'POST create' do
    let(:staging) { instance_double(Staging, save: false, errors: { base: ['invalid'] }) }
    let(:json_attributes) { { collection_create_attributes: { name: 'Invalid collection' } } }

    before do
      allow(Staging).to receive(:new).and_return(staging)
      post :create, params: { staging: json_attributes }, format: :json
    end

    it 'returns unprocessable content for invalid json input' do
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe 'PATCH update' do
    let(:staging) { instance_double(Staging, update: false, errors: { base: ['invalid'] }) }
    let(:json_attributes) { { collection_create_attributes: { name: 'Invalid collection' } } }

    before do
      allow(Staging).to receive(:find).with(staging_id).and_return(staging)
      patch :update, params: { id: staging_id, staging: json_attributes }, format: :json
    end

    it 'returns unprocessable content for invalid json input' do
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end