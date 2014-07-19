class Board < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User'
  has_one :linked_board, :class_name => 'Board'
  belongs_to :alias_board, :class_name => 'Board'
end
