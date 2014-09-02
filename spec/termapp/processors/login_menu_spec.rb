require 'rails_helper'
require 'processor'
require 'processors/login_menu'

RSpec.describe LoginMenu, type: :termapp do
  it_behaves_like 'a processor'
end
