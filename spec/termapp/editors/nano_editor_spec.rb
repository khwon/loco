require 'rails_helper'
require 'terminal'
require 'editor'
require 'editors/nano_editor'

RSpec.describe TermApp::NanoEditor, type: :termapp do
  it_behaves_like 'an editor'
end
