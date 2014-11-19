shared_examples 'an editor' do
  subject(:editor) { described_class.new(term) }
  let(:term) { silence_warnings { TermApp::Terminal.new } }
  after(:example) { term.terminate }

  describe '#method_missing' do
    [
      [:beep],
      [:mvaddstr, 0, 0, 'foo'],
      [:getyx],
      [:erase_all],
      [:get_wch]
    ].each do |method, *args|
      it "delegates #{method} to term" do
        if args.empty?
          expect(term).to receive(method).with(no_args)
        else
          expect(term).to receive(method).with(*args)
        end
        editor.send(method, *args)
      end
    end
  end
end
