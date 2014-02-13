class User < ActiveRecord::Base
  validates :email, :presence => true, :uniqueness => true
  validates :user_name, :presence => true
  validates :password, :presence => true
  validates :rights, :presence => true

  has_many :votes
  has_many :posts
end
