require 'rails_helper'
require 'core_ext/string'
require 'locoterm'

RSpec.describe String, type: :termapp do
  describe '#size_for_print' do
    before(:context) do
      @locoterm = LocoTerm.new
    end

    after(:context) do
      @locoterm.terminate
    end

    it 'returns 1 for ASCII characters' do
      # FIXME
      # 1 => 0
      # 2 => 2
      # 3 => 2
      # 4 => 2
      # 5 => 2
      # 6 => 2
      # 7 => 2
      # 8 => 0
      # 9 => 8
      # 10 => [1, 0]
      # 11 => 2
      # 12 => 2
      # 13 => 0
      # 14 => 2
      # 15 => 2
      # 16 => 2
      # 17 => 2
      # 18 => 2
      # 19 => 2
      # 20 => 2
      # 21 => 2
      # 22 => 2
      # 23 => 2
      # 24 => 2
      # 25 => 2
      # 26 => 2
      # 27 => 2
      # 28 => 2
      # 29 => 2
      # 30 => 2
      # 31 => 2
      # 127 => 2
      (32..126).each do |ascii|
        @locoterm.mvaddstr(0, 0, ascii.chr)
        expect([ascii, [0, 1]]).to eq([ascii, @locoterm.getyx])
      end
    end

    it 'returns the size to pring on Ncurses screen' do
      # FIXME
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
        # 'å∫ç', => 3
        '　',
        # '★', => 1
        # '​' => 1
      ].each do |str|
        @locoterm.mvaddstr(0, 0, str)
        expect([0, str.size_for_print]).to eq(@locoterm.getyx)
      end
    end
  end
end
