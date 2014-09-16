require 'rails_helper'
require 'processor'
require 'processors/not_implemented_menu'

RSpec.describe NotImplementedMenu, type: :termapp do
  it_behaves_like 'a processor'
end
