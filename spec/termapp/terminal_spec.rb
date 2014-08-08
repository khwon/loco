require 'rails_helper'
require 'terminal'

RSpec.describe TermApp::Terminal, type: :termapp do
  subject { silence_warnings { TermApp::Terminal.new } }
  after(:example) do
    subject.terminate
  end

  it do
    is_expected.to respond_to(:erase,
                              :noecho,
                              :echo,
                              :beep,
                              :terminate,
                              :refresh,
                              :move,
                              :getch)
  end

  describe '.color_<color>' do
    it do
      is_expected.to respond_to(
                       *TermApp::Terminal.const_get(:COLOR_SYMBOLS))
    end
  end
end
