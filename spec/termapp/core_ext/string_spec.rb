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
      (32..126).each do |ascii|
        @locoterm.mvaddstr(0, 0, ascii.chr)
        expect([ascii, [0, 1]]).to eq([ascii, @locoterm.getyx])
      end
    end

    it 'returns the size to pring on Ncurses screen' do
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
