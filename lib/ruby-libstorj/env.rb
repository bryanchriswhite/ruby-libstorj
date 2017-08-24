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
      uv_queue_and_run do
        req_data_type = ::LibStorj::Ext::Storj::JsonRequest
        ::LibStorj::Ext::Storj.get_info @storj_env,
                                        ruby_handle(&block),
                                        after_work_cb(req_data_type)
      end
    end

    def get_buckets(&block)
      uv_queue_and_run do
        req_data_type = ::LibStorj::Ext::Storj::GetBucketRequest
        ::LibStorj::Ext::Storj.get_buckets @storj_env,
                                           ruby_handle(&block),
                                           after_work_cb(req_data_type)
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
        error = curl_error_code_to_string req[:error_code]
        response = json_c_to_string req[:response]
        c_handle = FFI::Function.new :void, %i[string string], req[:handle]

        # default error
        error = 'Failed to get info' if error.nil? && (response.nil? || response.empty?)

        # call sequence: `c_handle` -> c ... -> `ruby_handle` -> `ruby_handle`'s block
        c_handle.call error, response
      end
    end

    private :after_work_cb

    def ruby_handle
      # do final data massaging to ruby here;
      # types are no longer restricted, no more pointers or casting
      FFI::Function.new :void, %i[string string] do |error, response|
        # begin
        response = JSON.parse response
        #   TODO: better error handling
        # rescue JSON::ParserError
        # end

        yield error, response
      end
    end

    private :ruby_handle
  end
end
