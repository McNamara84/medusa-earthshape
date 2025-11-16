require 'spec_helper'

# Minimal controller test - no actual controller, just check if type: :controller hangs
RSpec.describe 'Minimal Controller Type Test', type: :controller do
  it 'runs without hanging' do
    puts '[DEBUG] Test started'
    expect(1).to eq(1)
    puts '[DEBUG] Test finished'
  end
end
