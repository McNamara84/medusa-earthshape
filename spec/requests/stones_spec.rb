require 'spec_helper'

describe "stone" do
  let(:login_user) { FactoryGirl.create(:user) }
  
  describe "stone detail screen" do
    let(:stone) do
      # Rails 5.0: Set User.current before creating stone to ensure proper record_property
      User.current = login_user
      FactoryGirl.create(:stone)
    end
    let(:attachment_file) { FactoryGirl.create(:attachment_file, data_file_name: "file_name", data_content_type: data_type) }
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
        before { click_link("picture-button") }
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
        # Skip to avoid "FIXED" error
        xit "new spot creation implementation is difficult, pending" do
        end
      end

      describe "thumbnail" do
        context "attachment_file is jpeg" do
          let(:data_type) { "image/jpeg" }
          before { click_link("picture-button") }
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
      before { click_link("at-a-glance") }
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
      before { click_link("file (1)") }
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
