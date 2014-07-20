class Board < ActiveRecord::Base
  belongs_to :owner, class_name: 'User'
  has_one :linked_board, class_name: 'Board'
  belongs_to :alias_board, class_name: 'Board'
  belongs_to :parent, class_name: 'Board'
  has_many :children, foreign_key: 'parent_id', class_name: 'Board', inverse_of: :parent

  attr_accessor :is_dir

  def self.get_list(parent: nil)
    if parent.nil?
      %w(Korea hackers asia europe northAmerica southAmerica oceania Africa pacific myGroup closed gon writers MySecret Cert).each_with_index.map{ |x,i| Board.new(id: i+2, name: x, is_dir: true) }
    else
      Board.new(id: 1,name: "test_board", is_dir: false)
    end
  end

  def path_name
    str = name
    str += "/" if self.is_dir
    str = self.parent.path_name + str unless self.parent.nil?
    str
  end

end
