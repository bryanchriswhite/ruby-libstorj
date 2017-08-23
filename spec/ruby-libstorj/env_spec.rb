require_relative '../helpers/storj_options'
include LibStorjTest

RSpec.shared_examples 'instance of described class' do
  let(:instance) do
    described_class.new(*default_options)
  end

  after do
    # (see https://github.com/Storj/ruby-libstorj/issues/2)
    # Process.RLIMIT_MEMLOCK #=> 8
    instance.destroy
  end
end

RSpec.describe LibStorj::Env, extra_broken: true do
  describe 'new' do
    include_examples 'instance of described class'

    it 'doesn\'t segfault' do
      # pass
    end

    it 'returns an instance of the described class' do
      expect(instance).to be_an_instance_of(described_class)
    end
  end

  describe '@pointer' do
    include_examples 'instance of described class'

    it 'does not point to NULL' do
      expect(instance.storj_env.to_ptr).not_to equal(FFI::Pointer::NULL)
    end

    it 'is an instance of the struct wrapper corresponding to its C analogue' do
      expect(instance.storj_env).to be_an_instance_of(described_class::C_ANALOGUE)
    end
  end

  describe '#get_info' do
    context 'without error' do
      include_examples 'instance of described class'

      it 'yields with an error value of `nil` and response matching regex: /^{\W+swagger/' do
        expect do |block|
          instance.get_info(&block)
        end.to yield_with_args(NilClass, /^{\W+swagger/)
      end
    end

    context 'with error' do
      include_examples 'instance of described class'

      it 'yields with a non-nil error value and "null" response' do
        instance.storj_env[:bridge_options][:host].write_string 'a.nonexistant.example'

        expect do |block|
          instance.get_info(&block)
        end.to yield_with_args(/couldn't resolve host name/i, 'null')
      end
    end
  end

  describe '#get_buckets' do
    # TODO: refactor error contexts into shared example group 'api request'
    context 'without error' do
      include_examples 'instance of described class'

      it 'yields a string response and a nil error' do
        expect do |block|
          instance.get_buckets(&block)
        end.to yield_with_args(NilClass, String)
      end

      it 'yields a response containing a JSON array of buckets with `name`s' do
        require 'json'

        instance.get_buckets do |error, response|
          buckets = JSON.parse response
          are_all_named = buckets.reject {|bucket| bucket[:name].nil?}.empty?

          expect(are_all_named).to be(true)
        end
      end
    end

    context 'with error' do
      include_examples 'instance of described class'

      it 'yields with a non-nil error value and "null" response' do
        # (see https://tools.ietf.org/html/rfc2606)
        instance.storj_env[:bridge_options][:host].write_string 'a.nonexistant.example'

        expect do |block|
          instance.get_buckets(&block)
        end.to yield_with_args(/couldn't resolve host name/i, 'null')
      end
    end

    # context 'with invalid credentials' do
    #
    # end
  end
end