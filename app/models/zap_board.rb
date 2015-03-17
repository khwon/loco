# Holds zapped Boards of User. Belongs to User and Board.
class ZapBoard < ActiveRecord::Base
  belongs_to :user
  belongs_to :board

  # Zap the Board from the User.
  #
  # board - The Board to zap.
  # user  - The User zapping.
  #
  # Returns nothing.
  def self.zap(board, user)
    model = ZapBoard.new
    model.board = board
    model.user = user
    model.save!
  end
end
