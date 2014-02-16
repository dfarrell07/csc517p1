class Category < ActiveRecord::Base
  validates :name, :presence => true, :uniqueness => true
  validates :status, :presence => true

  has_many :posts
end
