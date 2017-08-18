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

    it 'returns an instance of the described class' do
      expect(@instance).to be_an_instance_of(described_class)
    end
  end

  describe '@pointer' do
    include_examples '@instance of described class'

    it 'does not point to NULL' do
      expect(@instance.pointer).not_to equal(FFI::Pointer::NULL)
    end

    it 'is an instance of the struct wrapper corresponding to its C analogue' do
      expect(@instance.pointer).to be_an_instance_of(described_class::C_ANALOGUE)
    end
  end

  describe '#get_info' do
    context 'without error' do
      include_examples '@instance of described class'

      it 'yields with an error value of `nil` and response matching regex: /^{\W+swagger/' do
        expect do |block|
          @instance.get_info(&block)
        end.to yield_with_args(NilClass, /^{\W+swagger/)
      end
    end

    context 'with error' do
      include_examples '@instance of described class'

      it 'yields with a non-nil error value' do
        @instance.pointer[:bridge_options][:host].write_string 'a.nonexistant.example'

        expect do |block|
          @instance.get_info(&block)
        end.to yield_with_args(/couldn't resolve host name/i, 'null')
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
        end.to yield_with_args(NilClass, /^(\[\s+)?{\W+user/)
      end
    end

    context 'with error' do
      include_examples '@instance of described class'

      it 'yields with a non-nil error value' do
        @instance.pointer[:bridge_options][:host].write_string 'a.nonexistant.example'

        expect do |block|
          @instance.get_info(&block)
        end.to yield_with_args(/couldn't resolve host name/i, 'null')
      end
    end
  end
end