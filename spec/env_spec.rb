require_relative './helpers/storj_options'
include LibStorjTest

RSpec.shared_examples '@instance of described class' do
  before do
    begin
      @instance = described_class.new(*default_options)
    rescue => error
      fail(error)
    end
  end
end

RSpec.describe LibStorj::Env do
  describe 'new' do
    include_examples '@instance of described class'

    it 'doesn\'t segfault' do
      # pass
    end

    it 'returns an instant of LibStorj::Env' do
      expect(@instance).to be_an_instance_of(described_class)
    end
  end

  describe '#get_info' do
    context 'no error' do
      include_examples '@instance of described class'

      it 'should yield with an error value of `nil`' do
        expect do |block|
          @instance.get_info &block
        end.to yield_with_args(NilClass, /^{[\s\W]+swagger/)
      end
    end
  end
end