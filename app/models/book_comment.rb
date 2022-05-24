class BookComment < ApplicationRecord
  belongs_to :user
  belongs_to :book
  
  validates :title,presence:true
  
end
