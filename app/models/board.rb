# Board information of Loco. Belongs to User. Can have a linked Board and belong
# to alias Board. Can have many Boards as children.
class Board < ActiveRecord::Base
  belongs_to :owner, class_name: 'User'
  has_one :linked_board, class_name: 'Board'
  belongs_to :alias_board, class_name: 'Board'
  belongs_to :parent, class_name: 'Board'
  has_many :children, foreign_key: 'parent_id', class_name: 'Board',
                      inverse_of: :parent

  has_many :post

  validates :name, presence: true, uniqueness: { scope: :parent }
  validates :owner, presence: true, unless: :is_dir

  # Child Board list of parent Board. If parent Board is nil, return root Board
  # list.
  #
  # option - The Hash options used to refine the parent Board
  #          (default: { parent_board: nil }):
  #          :parent_board - The Board which is wanted to get child list of it
  #                          (optional).
  #
  # Examples
  #
  #   Board.get_list
  #   # => #<ActiveRecord::Relation [
  #   #      #<Board is_dir: true, name: 'Korea'>,
  #   #      #<Board is_dir: true, name: 'hackers'>,
  #   #      #<Board is_dir: true, name: 'asia'>,
  #   #      #<Board is_dir: true, name: 'europe'>,
  #   #      #<Board is_dir: true, name: 'northAmerica'>,
  #   #      #<Board is_dir: true, name: 'southAmerica'>,
  #   #      #<Board is_dir: true, name: 'oceania'>,
  #   #      #<Board is_dir: true, name: 'Africa'>
  #   #    ]>
  #
  #   Board.get_list(parent_board: Board.find_by(name: 'Korea'))
  #   # => #<ActiveRecord::Associations::CollectionProxy [
  #   #      #<Board is_dir: false, parent_id: 1, name: 'a'>,
  #   #      #<Board is_dir: false, parent_id: 1, name: 'b'>,
  #   #      #<Board is_dir: false, parent_id: 1, name: 'c'>,
  #   #      #<Board is_dir: false, parent_id: 1, name: 'd'>
  #   #    ]>
  #
  # Returns an Array of Board which is child of parent Board or an Array of
  #   Board which doesn't have parent.
  def self.get_list(parent_board: nil)
    if parent_board
      parent_board.children
    else
      Board.where(parent_id: nil)
    end
  end

  # Find the Board specified by its path.
  #
  # Returns the Board specified by its path, nil if there is no such Board.
  def self.find_by_path(str)
    arr = str.split('/')
    b = Board.find_by(name: arr[0], parent_id: nil)
    arr[1..-1].each do |x|
      b = b.children.find_by(name: x) if b
    end
    b
  end

  # Full path name of the Board. It has suffix '/' if the Board is directory.
  #
  # Examples
  #
  #   path_name
  #   # => 'Korea/'
  #
  #   path_name
  #   # => 'Korea/a'
  #
  # Returns the String full path of the Board.
  def path_name
    str = name
    str << '/' if is_dir
    str = parent.path_name + str if parent
    str
  end

  # Search every non-directory child Boards.
  #
  # Returns an Array of child Boards which is not a directory, including
  #   children of child Boards.
  def leaves
    result = children.where(is_dir: false).to_a
    dirs = children.where(is_dir: true).to_a
    while dirs.size > 0
      child = dirs.pop
      dirs << child.children.where(is_dir: true)
      result << child.children.where(is_dir: false)
    end
    result
  end

  # List of post having num which is greater than or equal to given num.
  #
  # num  - The Integer num which is the lowest value of list.
  # size - The Integer max size of the list.
  #
  # Returns an Array of Post ordered by num.
  def posts_from(num, size)
    post.order('num asc').limit(size).where('num >= ?', num)
  end

  # List of post having num which is smaller than or equal to given num.
  #
  # num  - The Integer num wihch is the highest value of list.
  # size - The Integer max size of the list.
  #
  # Returns an Array of Post ordered by num.
  def posts_to(num, size)
    post.order('num desc').limit(size).where('num <= ?', num).reverse
  end
end
