require_relative '../helpers/storj_options'
include LibStorjTest

RSpec.describe LibStorj::Env do
  let(:bucket_class) {::LibStorj::Ext::Storj::Bucket}
  let(:instance) do
    described_class.new(*default_options)
  end

  after :each do
    # (see https://github.com/Storj/ruby-libstorj/issues/2)
    # Process.RLIMIT_MEMLOCK #=> 8
    instance.destroy
  end

  describe '.uv_queue_and_run' do
    before :all do
      module LibStorj
        class Env
          def uv_queue_and_run_test_proxy(*args, &block)
            uv_queue_and_run(*args, &block)
          end
        end
      end
    end

    context 'without error' do
      it 'yields the block asynchronously' do
        expect do |block|
          instance.uv_queue_and_run_test_proxy(&block)
        end.to yield_control
      end

      it 'returns a promise' do
        expect(instance.uv_queue_and_run_test_proxy do
          #-- noop
        end).to respond_to(:then, :catch)
      end
    end

    context 'catching an async error' do
      let(:test_error) {Exception.new 'test exception'}

      it 'raises an `ArgumentError`' do
        expect do
          instance.uv_queue_and_run_test_proxy do
            raise(test_error)
          end
        end.to raise_error(test_error)
      end
    end
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
        instance.get_info do |error, info|
          expect(error).to be(nil)
          expect(info).to be_an_instance_of(Hash)
        end
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
    context 'without error' do
      it 'yields a nil error and an array of buckets' do
        expect do |block| #{|block| instance.get_bucekts(&block)}.to yield_with_args
          instance.get_buckets do |error, buckets|
            expect(error).to be(nil)
            expect(buckets).to be_an_instance_of(Array)
            expect(buckets).to satisfy do |_buckets|
              _buckets.all? do |bucket|
                bucket.is_a? bucket_class
              end
            end
          end
        end
      end

      it 'yields an array of buckets' do
        instance.get_buckets do |error, buckets|
          expect(buckets).to satisfy do |buckets|
            buckets.all? do |bucket|
              bucket.is_a? bucket_class
            end
          end
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
  end

  def get_test_bucket_id(&block)
    instance.get_buckets do |error, buckets|
      test_bucket = buckets.find {|bucket| bucket.name == test_bucket_name}
      throw(:no_bucket) unless test_bucket
      block.call test_bucket.id
    end
  end

  describe '#create_bucket' do
    let(:test_bucket_name) {'__ruby-libstorj_test'}

    # TODO: refactor error contexts into shared example group 'api request'
    context 'without error' do
      let(:bucket_class) {::LibStorj::Ext::Storj::Bucket}

      def clean_buckets(&block)
        catch(:no_bucket) do
          return get_test_bucket_id do |id|
            instance.delete_bucket(id, &block)
          end
        end

        yield
      end

      it 'yields with nil error and the new bucket' do
        clean_buckets do
          instance.create_bucket(test_bucket_name) do |error, bucket|
            expect(error).to be(nil)
            expect(bucket).to be_an_instance_of(bucket_class)
          end
        end
      end
    end

    context 'with error' do
      describe 'external error' do
        it 'yields with a non-nil error value and nil response' do
          # (see https://tools.ietf.org/html/rfc2606)
          instance.storj_env[:bridge_options][:host].write_string 'a.nonexistant.example'

          expect do |block|
            instance.create_bucket(test_bucket_name, &block)
          end.to yield_with_args(/couldn't resolve host name/i, nil)
        end
      end

      describe 'bucket name in use' do
        before do
          instance.create_bucket(test_bucket_name)
        end

        it 'yields with a bucket name in use error' do
          # (see https://tools.ietf.org/html/rfc2606)
          expect do |block|
            instance.create_bucket(test_bucket_name, &block)
          end.to yield_with_args(/name already used by another bucket/i, nil)
        end
      end
    end
  end

  describe '#delete_bucket' do
    let(:test_bucket_name) {'__ruby-libstorj_test'}

    before :each do
      instance.create_bucket(test_bucket_name)
    end

    # TODO: refactor error contexts into shared example group 'api request'
    context 'without error' do
      let(:bucket_class) {::LibStorj::Ext::Storj::Bucket}

      it 'yields with nil error' do
        get_test_bucket_id do |id|
          instance.delete_bucket(id) do |error|
            expect(error).to be(nil)
          end
        end
      end
    end

    context 'with error' do
      describe 'external error' do
        it 'yields with a non-nil error value and nil response' do
          # (see https://tools.ietf.org/html/rfc2606)
          instance.storj_env[:bridge_options][:host].write_string 'a.nonexistant.example'

          expect do |block|
            instance.delete_bucket(test_bucket_name, &block)
          end.to yield_with_args(/couldn't resolve host name/i)
        end
      end

      describe 'malformed id error' do
        let(:malformed_bucket_id) {'__ruby-libstorj_test-non-existant'}

        it 'yields with a malformed id error' do
          instance.delete_bucket(malformed_bucket_id) do |error|
            expect(error).to match(/bucket id is malformed/i)
          end
        end
      end
    end
  end
end
