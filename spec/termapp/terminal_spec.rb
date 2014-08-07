require 'rails_helper'
require 'terminal'

RSpec.describe TermApp::Terminal, type: :termapp do
  around(:example) do |example|
    suppress_warnings { @term = TermApp::Terminal.new }
    example.run
    @term.terminate
  end

  context 'with delegators' do
    %i(erase noecho echo beep terminate refresh move getch).each do |method|
      it "responds to #{method}" do
        expect(@term.respond_to? method).to be true
      end
    end
  end
end
