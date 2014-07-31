require 'rails_helper'
require 'core_ext/string'
require 'terminal'

RSpec.describe String, type: :termapp do
  describe '#size_for_print' do
    before(:context) do
      @term = TermApp::Terminal.new
    end

    after(:context) do
      @term.terminate
    end

    it 'fails on control characters' do
      # TODO: Fails on 0 < ord < 32 || 127 <= ord < 160
      # Use Array#pack('U') instead of Integer#chr because of encoding problem.
      pending 'need to be implemented'
      [*1..31, *127..159].each do |ch|
        expect([ch].pack('U').size_for_print).to raise_error
      end
    end

    it 'returns the appropriate size for every ASCII characters' do
      [0, *32..126].each do |ascii|
        @term.mvaddstr(0, 0, ascii.chr)
        expect([ascii, ascii.chr.size_for_print]).to eq([ascii, @term.getyx[1]])
      end
    end

    it 'returns the size to print on Ncurses screen' do
      [
        '가',
        '가나',
        '가나foo',
        'foo가나',
        '가foo나',
        '가나123',
        '가 나',
        'あい',
        '가あ',
        '單語',
        '　',
        # FIXME
        # 'å∫ç' expectd to be 4, got 3
        # '★' expectd to be 2, got 1
        # '​' expectd to be 1, got 0
      ].each do |str|
        @term.mvaddstr(0, 0, str)
        expect([str, str.size_for_print]).to eq([str, @term.getyx[1]])
      end
    end
  end
end
