class Post < ApplicationRecord
  belongs_to :user
  belongs_to :topic

  validates_presence_of :user
  validates_presence_of :topic

  validates_with OnehashValidator
end
