require 'rails_helper'
require 'terminal'

RSpec.describe TermApp::Terminal, type: :termapp do
  context 'with delegators' do
    around(:example) do |example|
      @term = TermApp::Terminal.new
      example.run
      @term.terminate
    end

    it 'responds to erase' do
      expect(@term.respond_to? :erase).to be true
    end

    it 'responds to noecho' do
      expect(@term.respond_to? :noecho).to be true
    end

    it 'responds to echo' do
      expect(@term.respond_to? :echo).to be true
    end

    it 'responds to beep' do
      expect(@term.respond_to? :beep).to be true
    end

    it 'responds to terminate' do
      expect(@term.respond_to? :terminate).to be true
    end

    it 'responds to refresh' do
      expect(@term.respond_to? :refresh).to be true
    end

    it 'responds to move' do
      expect(@term.respond_to? :move).to be true
    end

    it 'responds to getch' do
      expect(@term.respond_to? :getch).to be true
    end
  end
end
