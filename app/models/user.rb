class User < ActiveRecord::Base
  has_secure_password validations: false

  def admin?
    # FIXME : implement admin? function
    username == 'a'
  end
end
