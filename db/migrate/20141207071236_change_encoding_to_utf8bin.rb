class ChangeEncodingToUtf8bin < ActiveRecord::Migration
  def change
    if ActiveRecord::Base.configurations[Rails.env]['adapter'].include? 'mysql'
      execute %{ALTER TABLE boards MODIFY name varchar(255) COLLATE utf8_bin DEFAULT NULL}
      execute %{ALTER TABLE users MODIFY username varchar(255) COLLATE utf8_bin DEFAULT NULL}
    end
  end
end
