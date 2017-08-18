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

RSpec.describe LibStorj::Env, extra_broken: true do
  describe 'new' do
    include_examples '@instance of described class'

    it 'doesn\'t segfault', working: true, broken: true do
      # pass
    end

    it 'returns an instance of the described class', working: true, broken: true do
      expect(@instance).to be_an_instance_of(described_class)
    end
  end

  describe '@pointer' do
    include_examples '@instance of described class'

    it 'does not point to NULL', working: true, broken: true do
      expect(@instance.storj_env.to_ptr).not_to equal(FFI::Pointer::NULL)
    end

    it 'is an instance of the struct wrapper corresponding to its C analogue', working: true, broken: true do
      expect(@instance.storj_env).to be_an_instance_of(described_class::C_ANALOGUE)
    end
  end

  describe '#get_info' do
    context 'without error' do
      include_examples '@instance of described class'

      it 'yields with an error value of `nil` and response matching regex: /^{\W+swagger/', working: true, broken: true do
        expect do |block|
          @instance.get_info(&block)
        end.to yield_with_args(NilClass, /^{\W+swagger/)
      end
    end

    context 'with error' do
      include_examples '@instance of described class'

      it 'yields with a non-nil error value and "null" response', working: true, broken: true do
        @instance.storj_env[:bridge_options][:host].write_string 'a.nonexistant.example'

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

      it 'yields a string response and a nil error', working: true, broken: true do
        expect do |block|
          @instance.get_buckets(&block)
        end.to yield_with_args(NilClass, String)
      end

      it 'yields a response containing a JSON array of buckets with `name`s,', working: false, broken: true do
        require 'json'

        @instance.get_buckets do |error, response|
          buckets = JSON.parse response
          are_all_named = buckets.reject {|bucket| bucket[:name].nil?}.empty?

          expect(are_all_named).to be(true)
        end
      end
    end

    context 'with error' do
      # include_examples '@instance of described class'

      it 'yields with a non-nil error value and "null" response', working: true, broken: true do
        ballz = LibStorj::Env.new(*default_options)
        # (see https://tools.ietf.org/html/rfc2606)
        ballz.storj_env[:bridge_options][:host].write_string 'a.nonexistant.example'

        expect do |block|
          ballz.get_buckets(&block)
        end.to yield_with_args(/couldn't resolve host name/i, 'null')
      end
    end

    context 'after about 9 instances' do
      # include_examples '@instance of described class'
      it 'blows up' do
        boom = LibStorj::Env.new(*default_options)
      end
    end

    context '...' do
      # include_examples '@instance of described class'

      it 'blows up' do
        boom = LibStorj::Env.new(*default_options)
      end
    end

    # context 'with invalid credentials' do
    #
    # end
  end
end