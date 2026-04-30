require 'spec_helper'
require 'securerandom'

describe "stone" do
  let(:unique_token) { SecureRandom.hex(6) }
  let(:login_user) do
    FactoryBot.create(:user, email: "#{unique_token}@example.com", username: "user_#{unique_token}")
  end
  
  describe "stone detail screen" do
    let(:stone) do
      # Rails 5.0: Set User.current before creating stone to ensure proper record_property
      User.current = login_user
      FactoryBot.create(
        :stone,
        name: "Stone #{unique_token}",
        place: FactoryBot.create(:place, name: "Place #{unique_token}"),
        box: FactoryBot.create(:box, name: "Box #{unique_token}"),
        classification: FactoryBot.create(
          :classification,
          name: "Classification #{unique_token}",
          full_name: "Classification #{unique_token}"
        ),
        physical_form: FactoryBot.create(:physical_form, name: "Physical Form #{unique_token}")
      )
    end
    let(:attachment_file) { FactoryBot.create(:attachment_file, data_file_name: "file_name", data_content_type: data_type) }
    let(:data_type) { "image/jpeg" }
    let(:skip_attachment) { false }
    
    before do
      # Rails 5.0: Login first, then create data, then visit show page directly
      login login_user
      stone.attachment_files << attachment_file unless skip_attachment
      visit stone_path(stone)
    end

    describe "view spot" do
      context "picture-button is display" do
        before { visit picture_stone_path(stone) }
        let(:data_type) { "image/jpeg" }
        it "new spot label is properly displayed" do
          expect(page).to have_content("new spot with link(ID")
          # new spot with link(ID) field has no value option, so empty state verification is not performed
          expect(page).to have_link("record-property-search")
          expect(page).to have_button("add new spot")
        end
      end
      context "picture-button is not display" do
        context "no attachment_file" do
          let(:skip_attachment) { true }
          it "picture-button not display" do
            expect(page).to have_no_link("picture-button")
          end
          it "new spot label not displayed" do
            expect(page).to have_no_content("new spot with link(ID")
            expect(page).to have_no_link("record-property-search")
            expect(page).to have_no_button("add new spot")
          end
        end
        context "attachment_file is pdf" do
          let(:data_type) { "application/pdf" }
          it "picture-button not display" do
            expect(page).to have_no_link("picture-button")
          end
          it "new spot label not displayed" do
            expect(page).to have_no_content("new spot with link(ID")
            expect(page).to have_no_link("record-property-search")
            expect(page).to have_no_button("add new spot")
          end
        end
      end

      describe "new spot" do
        before { visit picture_stone_path(stone) }

        it "creates a spot with the default picture form values" do
          expect { click_button("add new spot") }.to change(Spot, :count).by(1)

          spot = attachment_file.spots.order(:id).last

          expect(spot).to have_attributes(
            target_uid: "",
            spot_x: 0.0,
            spot_y: 0.0,
            radius_in_percent: 2.0
          )
          expect(spot.name).to eq("untitled point 1")
        end
      end

      describe "thumbnail" do
        context "attachment_file is jpeg" do
          let(:data_type) { "image/jpeg" }
          before { visit picture_stone_path(stone) }
          it "image/jpeg is displayed" do
            expect(page).to have_css("div.spot-thumbnails img")
          end
        end
        context "attachment_file is pdf" do
          let(:data_type) { "application/pdf" }
          it "picture-button not display" do
            expect(page).to have_no_link("picture-button")
          end
        end
      end
    end
    
    describe "at-a-glance tab" do
      before { visit stone_path(stone, tab: "at-a-glance") }
      describe "pdf icon" do
        context "data_content_type is pdf" do
          let(:data_type) { "application/pdf" }
          it "show icon" do
            expect(page).to have_link("file-#{attachment_file.id}-button")
          end
        end
        context "data_content_type is jpeg" do
          let(:data_type) { "image/jpeg" }
          it "do not show icon" do
            expect(page).not_to have_link("file-#{attachment_file.id}-button")
          end
        end
      end
    end
    
    describe "file tab" do
      before { visit stone_path(stone, tab: "file") }
      describe "pdf icon" do
        context "data_content_type is pdf" do
          let(:data_type) { "application/pdf" }
          it "show icon" do
            expect(page).to have_link("file-#{attachment_file.id}-button")
          end
        end
        context "data_content_type is jpeg" do
          let(:data_type) { "image/jpeg" }
          it "do not show icon" do
            expect(page).not_to have_link("file-#{attachment_file.id}-button")
          end
        end
      end
    end
  end
  
end
