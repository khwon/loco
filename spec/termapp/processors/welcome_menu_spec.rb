require 'rails_helper'
require 'processor'
require 'processors/welcome_menu'

RSpec.describe WelcomeMenu, type: :termapp do
  it_behaves_like 'a processor'
end
