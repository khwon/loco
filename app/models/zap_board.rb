class ZapBoard < ActiveRecord::Base
  belongs_to :user
  belongs_to :board

  def self.zap(board, user)
    model = ZapBoard.new
    model.board = board
    model.user = user
    model.save!
  end
end
