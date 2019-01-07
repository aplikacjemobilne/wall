class User < ApplicationRecord
  has_many :posts
  has_many :topics

  has_secure_password
  has_secure_token

  validates_presence_of     :password
  validates_confirmation_of :password
  validates_presence_of :password_confirmation, if: :password_digest_changed?

  validates :username, presence: true, uniqueness: true
end
