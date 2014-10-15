# Post information of Loco. Belong to Board and User. Can have many Post as
# replies.
class Post < ActiveRecord::Base
  belongs_to :board
  belongs_to :parent, class_name: 'Post'
  belongs_to :writer, class_name: 'User'
  has_many :replies, foreign_key: 'parent_id', class_name: 'Post',
                     inverse_of: :parent

  validates :board, presence: true
  validates :writer, presence: true
  validates :num, presence: true, uniqueness: { scope: :board },
                  numericality: { only_integer: true,
                                  greater_than_or_equal_to: 1 }
end
