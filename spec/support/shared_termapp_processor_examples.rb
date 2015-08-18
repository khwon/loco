shared_examples 'a processor' do
  subject(:processor) { described_class }

  describe '#process' do
    it { expect(processor.instance_methods(true)).to include(:process) }
  end
end
