require 'rails_helper'
require 'terminal'
require 'editor'
require 'editors/less_editor'

RSpec.describe TermApp::LessEditor, type: :termapp do
  it_behaves_like 'an editor'
end
