class Board < ActiveRecord::Base
  belongs_to :owner, class_name: 'User'
  has_one :linked_board, class_name: 'Board'
  belongs_to :alias_board, class_name: 'Board'
  belongs_to :parent, class_name: 'Board'
  has_many :children, foreign_key: 'parent_id', class_name: 'Board',
                      inverse_of: :parent

  has_many :post

  def self.get_list(parent_board: nil)
    if parent_board
      parent_board.children
    else
      Board.where(parent_id: nil)
    end
  end

  def path_name
    str = name
    str += '/' if is_dir
    str = parent.path_name + str unless parent.nil?
    str
  end
end
