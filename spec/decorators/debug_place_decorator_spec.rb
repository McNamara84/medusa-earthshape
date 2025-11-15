require File.expand_path('../../spec_helper', __FILE__)

RSpec.describe "PlaceDecorator Debug", type: :decorator do
  let!(:place) { FactoryGirl.create(:place) }
  
  it "creates place successfully" do
    puts "Place created: #{place.inspect}"
    puts "Place latitude: #{place.latitude.inspect}"
    puts "Place longitude: #{place.longitude.inspect}"
    expect(place).to be_persisted
  end
  
  it "creates stone successfully" do
    stone = FactoryGirl.create(:stone, name: "TestStone", place: place)
    puts "Stone created: #{stone.inspect}"
    puts "Stone place: #{stone.place.inspect}"
    expect(stone).to be_persisted
  end
  
  it "loads stones association" do
    stone = FactoryGirl.create(:stone, name: "TestStone", place: place)
    puts "Loading place.stones..."
    stones = place.stones
    puts "Stones count: #{stones.count}"
    puts "Stones: #{stones.map(&:name).inspect}"
    expect(stones.count).to eq(1)
  end
  
  it "calls stones_summary" do
    stone = FactoryGirl.create(:stone, name: "TestStone", place: place)
    puts "Calling place.decorate..."
    decorated = place.decorate
    puts "Decorated: #{decorated.class}"
    puts "Calling stones_summary..."
    result = decorated.stones_summary
    puts "Result: #{result.inspect}"
    expect(result).to include("TestStone")
  end
end
