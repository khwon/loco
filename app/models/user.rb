# User information of Loco.
class User < ActiveRecord::Base
  has_secure_password validations: false
  validates :username, uniqueness: true, length: { minimum: 1 }

  # Check if the User is admin.
  #
  # Returns a Boolean whether the User is admin or not.
  def admin?
    # FIXME: Implement admin? function.
    username == 'SYSOP'
  end

  # Authenticate with password. Crypt old style password.
  #
  # pw - A String password that user inputted.
  #
  # Returns a User for correct password, false otherwise.
  def auth(pw)
    return nil unless is_active
    if old_crypt_password
      if pw.crypt(old_crypt_password[0..1]) == old_crypt_password
        self.password = pw
        self.old_crypt_password = nil
        save!
        self
      else
        false
      end
    else
      authenticate(pw)
    end
  end
end
