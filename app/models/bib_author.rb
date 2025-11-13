class BibAuthor < ApplicationRecord
  belongs_to :bib
  belongs_to :author
  
  #TODO bibの新規作成時にexistenceバリデーションが掛かるため一旦コメントアウト
  #validates :bib, existence: true
  # Rails 5.1: Removed validates :author, existence: true - belongs_to (required by default) handles this
end
