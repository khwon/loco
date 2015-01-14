# Holds favorited Boards of User. Belongs to User and Board.
class FavBoard < ActiveRecord::Base
  belongs_to :user
  belongs_to :board
end
