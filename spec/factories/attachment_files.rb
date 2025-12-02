FactoryBot.define do
  factory :attachment_file do
    association :filetopic, factory: :filetopic
    name { "添付ファイル１" }
    description { "説明１" }
    md5hash { "abcde" }
    # Use actual file for Paperclip validation in Rails 8.1+
    data { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'files', 'test_image.jpg'), 'image/jpeg') }
    original_geometry { "123x123" }
    affine_matrix { [1,0,0,0,1,0,0,0,1] }
  end
end
