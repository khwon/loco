require 'rails_helper'
require 'terminal'

RSpec.describe TermApp::Terminal, type: :termapp do
  subject { silence_warnings { TermApp::Terminal.new } }
  after(:example) do
    subject.terminate
  end

  %i(erase noecho echo beep terminate refresh move getch).each do |method|
    it { is_expected.to respond_to(method) }
  end

  describe '.color_<color>' do
    TermApp::Terminal.const_get(:COLOR_SYMBOLS).each do |color_method|
      it { is_expected.to respond_to(color_method) }
    end
  end
end
