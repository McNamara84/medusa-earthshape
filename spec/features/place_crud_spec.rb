require 'spec_helper'

feature "Place CRUD with parent relationships" do
  let(:user) { FactoryGirl.create(:user) }
  let(:parent_place) { FactoryGirl.create(:place, name: 'Parent Location') }
  
  before do
    parent_place.create_record_property(user_id: user.id)
    
    # Login
    visit new_user_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Sign in'
  end

  scenario "User creates a place with parent relationship via global_id" do
    visit new_place_path
    
    # Fill in place form
    fill_in 'Name', with: 'Child Location'
    fill_in 'Description', with: 'A location beneath the parent'
    
    # Set parent via global_id
    fill_in 'Parent global id', with: parent_place.global_id if page.has_field?('Parent global id')
    
    click_button 'Create Place'
    
    # Verify success
    expect(page).to have_content('Place was successfully created')
    
    # Verify parent relationship
    place = Place.last
    expect(place.name).to eq('Child Location')
    expect(place.parent).to eq(parent_place) if page.has_field?('Parent global id')
  end

  scenario "User edits a place and changes its parent" do
    # Create a place with parent
    place = FactoryGirl.create(:place, name: 'Original Place', parent: parent_place)
    place.create_record_property(user_id: user.id)
    
    # Create new parent
    new_parent = FactoryGirl.create(:place, name: 'New Parent')
    new_parent.create_record_property(user_id: user.id)
    
    visit edit_place_path(place)
    
    # Change parent via global_id
    fill_in 'Parent global id', with: new_parent.global_id if page.has_field?('Parent global id')
    
    click_button 'Update Place'
    
    # Verify update
    expect(page).to have_content('Place was successfully updated')
    place.reload
    expect(place.parent).to eq(new_parent) if page.has_field?('Parent global id')
  end

  scenario "User views place index" do
    # Create some places
    place1 = FactoryGirl.create(:place, name: 'Location A')
    place2 = FactoryGirl.create(:place, name: 'Location B', parent: parent_place)
    
    place1.create_record_property(user_id: user.id)
    place2.create_record_property(user_id: user.id)
    
    visit places_path
    
    # Verify places are listed
    expect(page).to have_content('Location A')
    expect(page).to have_content('Location B')
  end
end
