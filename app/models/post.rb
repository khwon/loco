class Post < ActiveRecord::Base
  belongs_to :board
  belongs_to :parent, class_name: 'Post'
  belongs_to :writer, class_name: 'User'
  has_many :replies, foreign_key: 'parent_id', class_name: 'Post',
                     inverse_of: :parent
end
