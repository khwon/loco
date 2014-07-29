class Board < ActiveRecord::Base
  belongs_to :owner, class_name: 'User'
  has_one :linked_board, class_name: 'Board'
  belongs_to :alias_board, class_name: 'Board'
  belongs_to :parent, class_name: 'Board'
  has_many :children, foreign_key: 'parent_id', class_name: 'Board',
                      inverse_of: :parent

  has_many :post

  def self.get_list(parent_board: nil)
    if parent_board.nil?
      %w(Korea
         hackers
         asia
         europe
         northAmerica
         southAmerica
         oceania
         Africa
         pacific
         myGroup
         closed
         gon
         writers
         MySecret
         Cert
      )
        .each_with_index
        .map { |x, i| Board.new(id: i + 2, name: x, is_dir: true) }
    else
      if parent_board.is_dir
        [Board.new(id: 1, name: 'board_' + parent_board.name, is_dir: false,
                   parent: parent_board)]
      else
        []
      end
    end
  end

  def path_name
    str = name
    str += '/' if is_dir
    str = parent.path_name + str unless parent.nil?
    str
  end
end
