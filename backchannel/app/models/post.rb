class Post < ActiveRecord::Base
  validates :title, :presence => true
  validates :message, :presence => true

  has_many :votes
  belongs_to :user
  belongs_to :category
end
