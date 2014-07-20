class User < ActiveRecord::Base
  def self.authorize(id, pw)
    if pw == 'a'
      return User.new(username: id)
    else
      return nil
    end
  end

  def admin?
    username.include? 'admin'
  end
end
