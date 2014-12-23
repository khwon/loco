class BoardRead < ActiveRecord::Base
  belongs_to :user
  belongs_to :board

  def self.mark_read(_user, _post, _board = nil)
    # TODO : implement
    fail NotImplementedError
  end

  def self.mark_visit(_user, _post, _board = nil)
    # TODO : implement
    fail NotImplementedError
  end
end
