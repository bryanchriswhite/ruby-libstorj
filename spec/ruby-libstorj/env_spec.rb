require_relative '../helpers/storj_options'
include LibStorjTest

RSpec.describe LibStorj::Env, extra_broken: true do
  let(:instance) do
    described_class.new(*default_options)
  end

  after :each do
    # (see https://github.com/Storj/ruby-libstorj/issues/2)
    # Process.RLIMIT_MEMLOCK #=> 8
    instance.destroy
  end

  describe 'new' do
    it 'returns an instance of the described class' do
      expect(instance).to be_an_instance_of(described_class)
    end
  end

  describe '@storj_env' do
    it 'does not point to NULL' do
      expect(instance.storj_env.to_ptr).not_to equal(FFI::Pointer::NULL)
    end

    it 'is an instance of the struct wrapper corresponding to its C analogue' do
      expect(instance.storj_env).to be_an_instance_of(described_class::C_ANALOGUE)
    end
  end

  describe '#get_info' do
    context 'without error' do
      it 'yields with an nil error and hash response' do
        expect do |block|
          instance.get_info(&block)
        end.to yield_with_args(NilClass, Hash)
      end
    end

    context 'with error' do
      it 'yields with an error and nil response' do
        instance.storj_env[:bridge_options][:host].write_string 'a.nonexistant.example'

        expect do |block|
          instance.get_info(&block)
        end.to yield_with_args(/couldn't resolve host name/i, nil)
      end
    end
  end

  describe '#get_buckets' do
    # TODO: refactor error contexts into shared example group 'api request'
    context 'without error' do
      it 'yields a nil error and an array of buckets' do
        expect do |block|
          instance.get_buckets(&block)
        end.to yield_with_args(NilClass, Array)
      end

      it 'yields an array of buckets with `name`s' do
        instance.get_buckets do |error, buckets|
          are_all_named = buckets.reject {|bucket| bucket[:name].nil?}.empty?

          expect(are_all_named).to be(true)
        end
      end
    end

    context 'with error' do
      it 'yields with a non-nil error value and nil response' do
        # (see https://tools.ietf.org/html/rfc2606)
        instance.storj_env[:bridge_options][:host].write_string 'a.nonexistant.example'

        expect do |block|
          instance.get_buckets(&block)
        end.to yield_with_args(/couldn't resolve host name/i, nil)
      end
    end

    # context 'with invalid credentials' do
    #
    # end
  end
end