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
      req_data_type = ::LibStorj::Ext::Storj::JsonRequest
      _after_work_cb = after_work_cb(req_data_type) do |req, error, response, handle|
        c_handle = FFI::Function.new :void, %i[string string], handle

        # call sequence: `c_handle` -> c ... -> `ruby_handle` -> `ruby_handle`'s block
        c_handle.call error, response
      end

      uv_queue_and_run do
        ::LibStorj::Ext::Storj.get_info @storj_env,
                                        ruby_handle(&block),
                                        _after_work_cb
      end
    end

    def get_buckets
      req_data_type = ::LibStorj::Ext::Storj::GetBucketRequest
      _after_work_cb = after_work_cb(req_data_type) do |req, error, response, handle|
        buckets, total_buckets = req.values_at %i[buckets total_buckets]

        c_handle = FFI::Function.new :void, %i[string pointer int], handle

        # call sequence: `c_handle` -> c ... -> `ruby_handle` -> `ruby_handle`'s block
        c_handle.call error, buckets, total_buckets
      end

      _ruby_handle = FFI::Function.new :void, %i[string pointer int] do
      |error, buckets_pointer, bucket_count|
        buckets = ::LibStorj::Ext::Storj::Bucket.pointer_to_array buckets_pointer, bucket_count
        yield error, buckets
      end

      uv_queue_and_run do
        ::LibStorj::Ext::Storj.get_buckets @storj_env,
                                           _ruby_handle,
                                           _after_work_cb
      end
    end

    def create_bucket(name)
      req_data_type = ::LibStorj::Ext::Storj::CreateBucketRequest
      _after_work_cb = after_work_cb(req_data_type) do |req, error, response, handle|
        bucket_struct = ::LibStorj::Ext::Storj::Bucket
        bucket = bucket_struct.new req[:bucket]

        c_handle = FFI::Function.new :void, %i[string pointer], handle


        # call sequence: `c_handle` -> c ... -> `ruby_handle` -> `ruby_handle`'s block
        c_handle.call error, bucket
      end
      _ruby_handle = FFI::Function.new :void, %i[string pointer] do |error, bucket_pointer|
        bucket = ::LibStorj::Ext::Storj::Bucket.new bucket_pointer
        yield error, bucket
      end

      uv_queue_and_run do
        ::LibStorj::Ext::Storj.create_bucket @storj_env,
                                             name,
                                             _ruby_handle,
                                             _after_work_cb
      end
    end

    def uv_queue_and_run
      reactor do |reactor|
        reactor.work do
          yield
        end
      end
    end

    private :uv_queue_and_run

    def curl_error_code_to_string(error_code)
      return nil if error_code.nil?

      curl_error = ::LibStorj::Ext::Curl.easy_stderr(error_code)
      error_code > 0 ? curl_error : nil
    end

    private :curl_error_code_to_string

    def json_c_to_string(json_c_obj)
      ::LibStorj::Ext::JsonC.parse_json json_c_obj
    end

    private :json_c_to_string

    def after_work_cb(req_data_type)
      args = [::LibStorj::Ext::UV::Work.ptr, :int]

      FFI::Function.new :void, args do |work_req_ptr|
        req = req_data_type.new work_req_ptr[:data]
        response = json_c_to_string req[:response]
        error = curl_error_code_to_string req[:error_code]
        handle = req[:handle]

        # default error
        error = 'Failed to create bucket' if error.nil? && (response.nil? || response.empty?)

        yield req, error, response, handle
      end
    end

    private :after_work_cb

    def ruby_handle
      # do final data massaging to ruby here;
      # types are no longer restricted, no more pointers or casting
      FFI::Function.new :void, %i[string pointer] do |error, response|
        # begin
        response = JSON.parse response.read_string
        #   TODO: better error handling
        # rescue JSON::ParserError
        # end

        yield error, response
      end
    end

    private :ruby_handle
  end
end
