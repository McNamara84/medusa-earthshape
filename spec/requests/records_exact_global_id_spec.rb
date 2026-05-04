require 'spec_helper'

describe 'records exact global ids' do
  let(:user) { FactoryBot.create(:user) }
  let(:stone) do
    User.current = user
    record = FactoryBot.create(:stone)
    record.record_property.update!(global_id: global_id)
    record
  end
  let(:global_id) { 'sample.id.v1.json' }

  before do
    login user
  end

  it 'resolves a show request for a global_id ending in .json' do
    stone

    get record_by_global_id_path(id: stone.record_property.global_id)

    expect(response).to redirect_to(stone_path(stone))
  end

  it 'supports path-based json format on the exact global-id route' do
    stone

    get formatted_record_by_global_id_path(id: stone.record_property.global_id, format: :json)

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq('application/json')
    expect(response.body).to include("\"global_id\":\"#{stone.record_property.global_id}\"")
  end

  it 'deletes through the exact global-id route' do
    stone

    expect {
      delete record_by_global_id_path(id: stone.record_property.global_id)
    }.to change(Stone, :count).by(-1)

    expect(response).to have_http_status(:redirect)
  end

  it 'supports formatted delete through the exact global-id route' do
    stone

    expect {
      delete formatted_record_destroy_by_global_id_path(id: stone.record_property.global_id, format: :json)
    }.to change(Stone, :count).by(-1)

    expect(response.status).to be_between(200, 299).inclusive
  end

  it 'resolves a global_id containing a slash through the exact route helper' do
    slash_stone = nil

    expect {
      slash_stone = FactoryBot.create(:stone)
      slash_stone.record_property.update!(global_id: 'folder/sample')
    }.not_to raise_error

    get record_by_global_id_path(id: slash_stone.record_property.global_id)

    expect(response).to redirect_to(stone_path(slash_stone))
  end

  it 'resolves property lookups for a global_id containing a slash' do
    slash_stone = nil

    expect {
      slash_stone = FactoryBot.create(:stone)
      slash_stone.record_property.update!(global_id: 'folder/sample')
    }.not_to raise_error

    get record_property_by_global_id_path(id: slash_stone.record_property.global_id, format: :json)

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq('application/json')
    expect(response.body).to include("\"global_id\":\"#{slash_stone.record_property.global_id}\"")
  end

  it 'resolves family lookups for a global_id containing a slash' do
    slash_stone = nil

    expect {
      slash_stone = FactoryBot.create(:stone)
      slash_stone.record_property.update!(global_id: 'folder/sample')
    }.not_to raise_error

    analysis = FactoryBot.create(:analysis)
    analysis.stones << slash_stone

    get families_by_global_id_path(id: slash_stone.record_property.global_id, format: :pml)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("<sample_global_id>#{slash_stone.global_id}")
  end
end