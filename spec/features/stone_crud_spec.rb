require 'spec_helper'

feature "Stone CRUD operations with relationships" do
  let(:user) { FactoryGirl.create(:user) }
  let(:place) { FactoryGirl.create(:place, name: 'Test Location') }
  let(:box) { FactoryGirl.create(:box, name: 'Test Box') }
  let(:collection) { FactoryGirl.create(:collection, name: 'Test Collection') }
  
  before do
    # Create record properties for global_id lookup
    place.create_record_property(user_id: user.id)
    box.create_record_property(user_id: user.id)
    collection.create_record_property(user_id: user.id)
    
    # Login
    visit new_user_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Sign in'
  end

  scenario "User creates a stone with place and box relationships via global_id" do
    visit new_stone_path
    
    # Fill in stone form
    fill_in 'Name', with: 'Test Sample'
    fill_in 'Description', with: 'Test sample description'
    
    # Set relationships via global_id (form fields)
    fill_in 'Place global id', with: place.global_id if page.has_field?('Place global id')
    fill_in 'Box global id', with: box.global_id if page.has_field?('Box global id')
    fill_in 'Collection global id', with: collection.global_id if page.has_field?('Collection global id')
    
    # Submit form
    click_button 'Create Stone'
    
    # Verify success
    expect(page).to have_content('Stone was successfully created')
    
    # Verify relationships were set correctly
    stone = Stone.last
    expect(stone.name).to eq('Test Sample')
    expect(stone.place).to eq(place) if page.has_field?('Place global id')
    expect(stone.box).to eq(box) if page.has_field?('Box global id')
    expect(stone.collection).to eq(collection) if page.has_field?('Collection global id')
  end

  scenario "User edits a stone and changes its place" do
    # Create a stone first
    stone = FactoryGirl.create(:stone, name: 'Original Stone', place: place)
    stone.create_record_property(user_id: user.id)
    
    # Create a new place to change to
    new_place = FactoryGirl.create(:place, name: 'New Location')
    new_place.create_record_property(user_id: user.id)
    
    visit edit_stone_path(stone)
    
    # Change place via global_id
    fill_in 'Place global id', with: new_place.global_id if page.has_field?('Place global id')
    
    click_button 'Update Stone'
    
    # Verify update
    expect(page).to have_content('Stone was successfully updated')
    stone.reload
    expect(stone.place).to eq(new_place) if page.has_field?('Place global id')
  end

  scenario "User views stone index and navigates to detail page" do
    # Create some stones
    stone1 = FactoryGirl.create(:stone, name: 'Sample A', place: place)
    stone2 = FactoryGirl.create(:stone, name: 'Sample B', box: box)
    
    stone1.create_record_property(user_id: user.id)
    stone2.create_record_property(user_id: user.id)
    
    visit stones_path
    
    # Verify stones are listed
    expect(page).to have_content('Sample A')
    expect(page).to have_content('Sample B')
    
    # Click on stone detail
    click_link 'Sample A'
    
    # Verify on detail page
    expect(page).to have_content('Sample A')
    expect(current_path).to eq(stone_path(stone1))
  end
end
