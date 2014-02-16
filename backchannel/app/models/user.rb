class User < ActiveRecord::Base
  #attr_accessor :password, :password_confirmation
  has_secure_password
  validates_presence_of :email
  validates_uniqueness_of :email
  validates :user_name, :presence => true
  validates :rights, :presence => true

  has_many :votes
  has_many :posts
end
