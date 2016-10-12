class AddFiletopicRefToAttachmentFile < ActiveRecord::Migration
  def change
    add_reference :attachment_files, :filetopic, index: true
  end
end
