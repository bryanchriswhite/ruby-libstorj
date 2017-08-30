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

        c_handle.call error, response
      end
      _ruby_handle = ruby_handle do |error, response|
        error = nil if error.empty?
        yield error, response
      end

      uv_queue_and_run do
        ::LibStorj::Ext::Storj.get_info @storj_env,
                                        _ruby_handle,
                                        _after_work_cb
      end
    end

    def delete_bucket(bucket_id, &block)
      req_data_type = ::LibStorj::Ext::Storj::JsonRequest
      _after_work_cb = after_work_cb(req_data_type) do |req, error, response_pointer, handle|
        c_handle = FFI::Function.new :void, %i[string], handle

        return c_handle.call(error) unless error.empty?
        status_code, response_pointer = req.values_at %i[status_code response]
        response = ::LibStorj::Ext::JsonC.stringify(response_pointer)

        if ((status_code > 299)) && error.empty?
          response_error = JSON.parse(response)['error']
          return c_handle.call(response_error)
        end

        c_handle.call error
      end

      _ruby_handle = FFI::Function.new :void, %i[string] do |error|
        yield(error.empty? ? nil : error) if block
      end

      uv_queue_and_run do
        ::LibStorj::Ext::Storj::Bucket.delete @storj_env,
                                              bucket_id,
                                              _ruby_handle,
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
        ::LibStorj::Ext::Storj::Bucket.all @storj_env,
                                           _ruby_handle,
                                           _after_work_cb
      end
    end

    def create_bucket(name, &block)
      req_data_type = ::LibStorj::Ext::Storj::CreateBucketRequest
      _after_work_cb = after_work_cb(req_data_type) do |req, error, response, handle|
        c_handle = FFI::Function.new :void, %i[string pointer], handle

        # require 'pry'
        # binding.pry
        return c_handle.call(error, ::FFI::MemoryPointer::NULL) unless error.empty?
        status_code, bucket = req.values_at %i[status_code bucket]
        if ((status_code > 299) || bucket.id.nil?) && error.empty?
          response_error = JSON.parse(response)['error']
          error = response_error
          return c_handle.call(error, ::FFI::MemoryPointer::NULL)
        end

        bucket_pointer = req[:bucket]
        c_handle.call nil, bucket_pointer
      end
      _ruby_handle = FFI::Function.new :void, %i[string pointer] do |error, bucket_pointer|
        bucket = bucket_pointer.null? ? nil : ::LibStorj::Ext::Storj::Bucket.new(bucket_pointer)
        yield error, bucket if block
      end

      uv_queue_and_run do
        ::LibStorj::Ext::Storj::Bucket.create @storj_env,
                                              name,
                                              _ruby_handle,
                                              _after_work_cb
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

    def curl_error_code_to_string(error_code)
      return nil if error_code.nil?

      curl_error = ::LibStorj::Ext::Curl.easy_stderr(error_code)
      error_code > 0 ? curl_error : ''
    end

    private :curl_error_code_to_string

    def json_c_to_string(json_c_obj)
      ::LibStorj::Ext::JsonC.stringify json_c_obj
    end

    private :json_c_to_string

    def after_work_cb(req_data_type)
      args = [::LibStorj::Ext::UV::Work.ptr, :int]

      FFI::Function.new :void, args do |work_req_ptr|
        req = req_data_type.new work_req_ptr[:data]
        response = json_c_to_string req[:response]
        error = curl_error_code_to_string req[:error_code]
        handle = req[:handle]

        yield req, error, response, handle
      end
    end

    private :after_work_cb

    def ruby_handle(&block)
      # do final data massaging to ruby here;
      # types are no longer restricted, no more pointers or casting
      FFI::Function.new :void, %i[string pointer] do |error, response|
        # begin
        response = JSON.parse response.read_string
        #   TODO: better error handling
        # rescue JSON::ParserError
        # end

        yield error, response if block
      end
    end

    private :ruby_handle
  end
end
