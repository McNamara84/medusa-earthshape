class Filetopic < ApplicationRecord
	has_many :attachment_files
	validates :name, presence: true, length: {maximum: 255}
end
