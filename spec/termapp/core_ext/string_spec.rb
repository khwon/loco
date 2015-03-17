# rubocop:disable Style/AsciiComments

require 'rails_helper'
require 'core_ext/string'
require 'terminal'

RSpec.describe String, type: :termapp do
  let(:term) { suppress_warnings { TermApp::Terminal.new } }
  after(:example) { term.terminate }

  describe '#size_for_print' do
    it 'fails on control characters' do
      # TODO: Fails on 0 < ord < 32 || 127 <= ord < 160.
      # Use Array#pack('U') instead of Integer#chr because of encoding problem.
      pending 'Not yet implemented'
      [*1..31, *127..159].each do |ch|
        expect([ch].pack('U').size_for_print).to raise_error
      end
    end

    [0, *32..126].each do |ascii|
      it "returns the size of ASCII character which of code #{ascii}" do
        term.mvaddstr(0, 0, ascii.chr)
        expect(ascii.chr.size_for_print).to eq(term.getyx[1])
      end
    end

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
      # FIXME: 'å∫ç' expectd to be 4, got 3.
      #   '★' expectd to be 2, got 1.
      #   '​' expectd to be 1, got 0.
    ].each do |str|
      it "returns the size of #{str} to print on Ncurses screen" do
        term.mvaddstr(0, 0, str)
        expect(str.size_for_print).to eq(term.getyx[1])
      end
    end
  end
end
