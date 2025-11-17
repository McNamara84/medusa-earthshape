require 'spec_helper'

RSpec.describe 'FactoryGirl in Controller Test', type: :controller do
  it 'creates user without hanging' do
    puts '[DEBUG] Creating user...'
    user = FactoryGirl.create(:user)
    puts "[DEBUG] User created: #{user.id}"
    expect(user).to be_present
    puts '[DEBUG] Test finished'
  end
end
