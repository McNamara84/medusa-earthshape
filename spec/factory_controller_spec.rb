require 'spec_helper'

RSpec.describe 'FactoryBot in Controller Test', type: :controller do
  it 'creates user without hanging' do
    puts '[DEBUG] Creating user...'
    user = FactoryBot.create(:user)
    puts "[DEBUG] User created: #{user.id}"
    expect(user).to be_present
    puts '[DEBUG] Test finished'
  end
end
