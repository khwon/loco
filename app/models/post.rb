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

  # Format the Post for display on terminal.
  #
  # size - The Integer max length of title.
  #
  # Returns the String displaying index of post.
  def format_for_term(size)
    strs = []
    strs << format('%6d', num)
    strs << format('%-12s', writer.nickname)
    strs << created_at.strftime('%m/%d') # Date
    strs << '????' # View count
    strs << title.unicode_slice(size)
    ' ' + strs.join(' ') # Cursor
  end

  def self.save_new_post(title: '', body: '', user: nil, board: nil)
    # TODO: Handle race condition about num.
    num = board.post.select('max(num) as max_num').first[:max_num] + 1
    post = Post.new(title: title,
                    content: body,
                    num: num)
    post.board = board
    post.writer = user
    post.save!
  end
end
