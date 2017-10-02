module LibStorj
  class Env
    require 'libuv'
    require 'json'
    attr_reader :storj_env

    C_ANALOGUE = ::LibStorj::Ext::Storj::Env

    def initialize(*options)
      @storj_env = ::LibStorj::Ext::Storj.method(:init_env).call(*options)
      @storj_env[:loop] = ::Libuv::Ext.default_loop
    end

    def destroy
      ::LibStorj::Ext::Storj.destroy_env @storj_env
    end

    def get_info(&block)
      ruby_handle = ::LibStorj::Ext::Storj::JsonRequest.ruby_handle(&block)
      after_work_cb = ::LibStorj::Ext::Storj::JsonRequest.after_work_cb do |error|
        yield error if block
      end

      uv_queue_and_run do
        ::LibStorj::Ext::Storj.get_info @storj_env,
                                        ruby_handle,
                                        after_work_cb
      end
    end

    def delete_bucket(bucket_id, &block)
      after_work_cb = ::LibStorj::Ext::Storj::JsonRequest.after_work_cb
      ruby_handle = ::LibStorj::Ext::Storj::JsonRequest.ruby_handle do |error|
        yield error if block
      end

      uv_queue_and_run do
        ::LibStorj::Ext::Storj::Bucket.delete @storj_env,
                                              bucket_id,
                                              ruby_handle,
                                              after_work_cb
      end
    end

    def get_buckets(&block)
      after_work_cb = ::LibStorj::Ext::Storj::GetBucketRequest.after_work_cb
      ruby_handle = ::LibStorj::Ext::Storj::GetBucketRequest.ruby_handle(&block)

      uv_queue_and_run do
        ::LibStorj::Ext::Storj::Bucket.all @storj_env,
                                           ruby_handle,
                                           after_work_cb
      end
    end

    def create_bucket(name, &block)
      req_data_type = ::LibStorj::Ext::Storj::CreateBucketRequest
      after_work_cb = req_data_type.after_work_cb
      ruby_handle = req_data_type.ruby_handle(&block)

      uv_queue_and_run do
        ::LibStorj::Ext::Storj::Bucket.create @storj_env,
                                              name,
                                              ruby_handle,
                                              after_work_cb
      end
    end

    def list_files(bucket_id, &block)
      req_data_type = ::LibStorj::Ext::Storj::ListFilesRequest
      after_work_cb = req_data_type.after_work_cb
      ruby_handle = req_data_type.ruby_handle(&block)

      uv_queue_and_run do
        ::LibStorj::Ext::Storj::File.all @storj_env,
                                         bucket_id,
                                         ruby_handle,
                                         after_work_cb
      end
    end

    def resolve_file(bucket_id, file_id, &block)
      download_state = ::LibStorj::Ext::Storj::DownloadState.new
      # file_descriptor = FFI::MemoryPointer.new(:char, 10000)

      require 'pry'
      progress_cb = FFI::Function.new :void, %i[double uint64 uint64 pointer] do
      |progress, bytes, total_bytes|
        # binding.pry
      end

      finished_cb = FFI::Function.new :void, %i[int pointer pointer] do
      |status, fd, handle|
        # binding.pry
        FFI::Function.new(:void, [], handle).call
      end

      ruby_handle = FFI::Function.new :void, [] do
        # binding.pry
        yield if block
      end

      uv_queue_and_run do
        ::LibStorj::Ext::Storj::File.resolve @storj_env,
                                             download_state,
                                             bucket_id,
                                             file_id,
                                             file_descriptor,
                                             ruby_handle,
                                             progress_cb,
                                             finished_cb
      end
    end

    def store_file(bucket_id, file_path, progress_block = nil, &block)
      upload_state = ::LibStorj::Ext::Storj::UploadState.new
      upload_options = ::LibStorj::Ext::Storj::UploadOptions.new bucket_id: bucket_id,
                                                                 file_path: file_path
      # upload_options = FFI::MemoryPointer::NULL

      progress_cb = FFI::Function.new :void, %i[double uint64 uint64 pointer] do
      |progress, bytes, total_bytes|
        # binding.pry
        puts 'hello from progress_cb'
        progress_block.call progress, bytes, total_bytes if progress_block
      end

      finished_cb = FFI::Function.new :void, %i[int pointer pointer] do
      |status, fd, handle|
        # binding.pry
        puts 'hello from finished_cb'
        FFI::Function.new(:void, [], handle).call
      end

      ruby_handle = FFI::Function.new :void, [] do
        # binding.pry
        puts 'hello from ruby_handle'
        yield if block
      end

      {upload_state: upload_state, upload_options: upload_options}.each do |name, value|
        if value.is_a? FFI::Struct
          puts "#{name}: #{value.to_ptr.address.to_s(16)}"
        else
          puts "#{name}: #{value.address.to_s(16)}"
        end
      end

      uv_queue_and_run do
        ::LibStorj::Ext::Storj::File.store @storj_env,
                                           upload_state,
                                           upload_options,
                                           ruby_handle,
                                           progress_cb,
                                           finished_cb

        upload_state.values_at(%i[original_file parity_file encrypted_file progress_cb finished_cb handle shard]).each do |pointer|
          puts "address: #{pointer.address.to_s(16)}"
        end
      end
    end

    def uv_queue_and_run
      reactor do |reactor|
        @chain = reactor.work do
          yield
        end.catch do |error|
          raise error
        end
      end
      @chain
    end

    private :uv_queue_and_run
  end
end
