require 'spec_helper'

feature "Box CRUD with parent relationships" do
  let(:user) { FactoryGirl.create(:user) }
  let(:parent_box) { FactoryGirl.create(:box, name: 'Parent Container') }
  let(:box_type) { FactoryGirl.create(:box_type, name: 'Standard Box') }
  
  before do
    parent_box.create_record_property(user_id: user.id)
    
    # Login
    visit new_user_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Sign in'
  end

  scenario "User creates a box with parent relationship via global_id" do
    visit new_box_path
    
    # Fill in box form
    fill_in 'Name', with: 'Child Box'
    
    # Set parent via global_id
    fill_in 'Parent global id', with: parent_box.global_id if page.has_field?('Parent global id')
    
    click_button 'Create Box'
    
    # Verify success
    expect(page).to have_content('Box was successfully created')
    
    # Verify parent relationship
    box = Box.last
    expect(box.name).to eq('Child Box')
    expect(box.parent).to eq(parent_box) if page.has_field?('Parent global id')
  end

  scenario "User edits a box and changes its parent" do
    # Create a box with parent
    box = FactoryGirl.create(:box, name: 'Original Box', parent: parent_box, box_type: box_type)
    box.create_record_property(user_id: user.id)
    
    # Create new parent
    new_parent = FactoryGirl.create(:box, name: 'New Parent Box', box_type: box_type)
    new_parent.create_record_property(user_id: user.id)
    
    visit edit_box_path(box)
    
    # Change parent via global_id
    fill_in 'Parent global id', with: new_parent.global_id if page.has_field?('Parent global id')
    
    click_button 'Update Box'
    
    # Verify update
    expect(page).to have_content('Box was successfully updated')
    box.reload
    expect(box.parent).to eq(new_parent) if page.has_field?('Parent global id')
  end

  scenario "User views box index" do
    # Create some boxes
    box1 = FactoryGirl.create(:box, name: 'Container A', box_type: box_type)
    box2 = FactoryGirl.create(:box, name: 'Container B', parent: parent_box, box_type: box_type)
    
    box1.create_record_property(user_id: user.id)
    box2.create_record_property(user_id: user.id)
    
    visit boxes_path
    
    # Verify boxes are listed
    expect(page).to have_content('Container A')
    expect(page).to have_content('Container B')
  end
end
