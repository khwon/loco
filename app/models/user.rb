class User < ActiveRecord::Base
  def self.authorize id,pw
    if id == "admin" and pw == "test"
      return User.new
    else
      return nil
    end
  end
end
