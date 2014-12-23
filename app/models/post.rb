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

  attr_accessor :read_status

  # Format the Post for display on terminal.
  #
  # size - The Integer max length of title.
  #
  # Returns the String displaying index of post.
  def format_for_term(size)
    strs = []
    strs << format('%6d', num)
    strs << (@read_status || 'N')
    name = writer.username.unicode_slice(12)
    name << ' ' * (12 - name.size_for_print)
    strs << name
    strs << created_at.strftime('%_m/%d') # Date
    strs << format('%4d', 22) # View count
    strs << title.unicode_slice(size)
    ' ' + strs.join(' ') # Cursor
  end

  # Save a new Post.
  #
  # options - The Hash option for creating a Post (default:
  #           { title: '', body: '', user: nil, board: nil }).
  #           :title - A String title of the Post (optional).
  #           :body  - A String content of the Post (optional).
  #           :user  - The User who wrote the Post.
  #           :board - The Board to write.
  #
  # Returns nothing.
  def self.save_new_post(title: '', body: '', user: nil, board: nil)
    # TODO: Handle race condition about num.
    num = (board.post.select('max(num) as max_num').first[:max_num] || 0) + 1
    post = Post.new(title: title,
                    content: body,
                    num: num)
    board.add_post(post)
    post.writer = user
    post.save!
  end
end
