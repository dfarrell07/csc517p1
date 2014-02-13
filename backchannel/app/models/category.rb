class Category < ActiveRecord::Base
  validates :name, :presence => true, :uniqeness => true
  validates :status, :presence => true

  has_many :posts
end
