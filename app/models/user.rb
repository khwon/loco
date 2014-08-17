# User information of Loco.
class User < ActiveRecord::Base
  has_secure_password validations: false

  # Check if the User is admin.
  #
  # Returns a Boolean whether the User is admin or not.
  def admin?
    # FIXME : implement admin? function
    username == 'a'
  end
end
