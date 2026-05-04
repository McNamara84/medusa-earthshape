require 'spec_helper'

describe 'records exact global ids' do
  let(:user) { FactoryBot.create(:user) }

  before do
    login user
  end

  it 'resolves a show request for a global_id ending in .json' do
    User.current = user
    stone = FactoryBot.create(:stone)
    stone.record_property.update!(global_id: 'sample.id.v1.json')

    get record_by_global_id_path(id: stone.record_property.global_id)

    expect(response).to redirect_to(stone_path(stone))
  end
end