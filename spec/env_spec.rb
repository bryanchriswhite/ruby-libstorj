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
    context 'without error' do
      include_examples '@instance of described class'

      it 'yields with an error value of `nil` and response matching regex: /^{\W+swagger/', debug: true do
        expect do |block|
          @instance.get_info(&block)
        end.to yield_with_args(NilClass, /^{\W+swagger/)
      end
    end

    # TODO: figure out how to create an error scenario
    context 'with error' do
      pending '# pending: figure out how wo create an error scenario'

      include_examples '@instance of described class'

      it 'yields with a non-nil error value' do
        expect do |block|
          @instance.get_info(&block)
        end.to yield_with_args()
      end
    end
  end

  describe '#get_buckets' do
    # TODO: refactor error contexts into shared example group 'api request'
    context 'without error' do
      include_examples '@instance of described class'

      it 'yields with an error value of `nil`' do
        expect do |block|
          @instance.get_buckets(&block)
        end.to yield_with_args(NilClass, /^{\W+swagger/)
      end
    end

    # TODO: figure out how to create an error scenario
    context 'with error' do
      pending '# pending: figure out how wo create an error scenario'

      include_examples '@instance of described class'

      it 'yields with a non-nil error value' do
        expect do |block|
          @instance.get_info(&block)
        end.to yield_with_args()
      end
    end
  end
end