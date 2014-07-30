require 'rails_helper'
require 'locoterm'

RSpec.describe LocoTerm, type: :termapp do
  context 'with delegators' do
    before(:context) do
      @locoterm = LocoTerm.new
    end

    after(:context) do
      @locoterm.terminate
    end

    it 'responds to erase' do
      expect(@locoterm.respond_to? :erase).to be true
    end

    it 'responds to noecho' do
      expect(@locoterm.respond_to? :noecho).to be true
    end

    it 'responds to echo' do
      expect(@locoterm.respond_to? :echo).to be true
    end

    it 'responds to beep' do
      expect(@locoterm.respond_to? :beep).to be true
    end

    it 'responds to terminate' do
      expect(@locoterm.respond_to? :terminate).to be true
    end

    it 'responds to refresh' do
      expect(@locoterm.respond_to? :refresh).to be true
    end

    it 'responds to move' do
      expect(@locoterm.respond_to? :move).to be true
    end

    it 'responds to getch' do
      expect(@locoterm.respond_to? :getch).to be true
    end
  end
end
