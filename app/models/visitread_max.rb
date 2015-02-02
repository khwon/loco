# Holds maximum number for posts user read/visited in board.
# Belongs to User and Board.
class VisitreadMax < ActiveRecord::Base
  belongs_to :user
  belongs_to :board
end
