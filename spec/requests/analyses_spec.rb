require 'spec_helper'

describe "analysis" do
  let(:login_user) { FactoryBot.create(:user) }
  
  describe "analysis detail screen" do
    let(:analysis) do
      # Rails 5.0: Set User.current before creating analysis to ensure proper record_property
      User.current = login_user
      FactoryBot.create(:analysis)
    end
    before do
      # Rails 5.0: Login first, then create data, then visit page
      login login_user
      analysis.attachment_files << attachment_file
      # Rails 5.0: Visit analysis show page directly to avoid index page readables filtering
      visit analysis_path(analysis)
    end
    let(:attachment_file) { FactoryBot.create(:attachment_file, data_file_name: "file_name", data_content_type: data_type) }
    
    describe "view spot" do
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
  end
  
end
