module LibStorj
  class Env
    require 'libuv'

    attr_reader :storj_env_ptr

    CURL_ERROR_CODE_CAST_PROC = Proc.new do |error_code|
      next nil if error_code.nil?

      curl_error = ::LibStorj::Ext::Curl.easy_stderr(error_code)
      error_code > 0 ? curl_error : nil
    end

    JSON_C_CAST_METHOD = ::LibStorj::Ext::JsonC.method :parse_json

    def initialize(*options)
      @storj_env_ptr = ::LibStorj::Ext::Storj.method(:init_env).call(*options)
      @storj_env_ptr[:loop] = ::Libuv::Ext.default_loop
    end

    def get_info(&block)
      handle_cast_proc = Proc.new do |handle|
        FFI::Function.new :void, %i[string string], handle
      end

      handle = Factory.error_response_callback(&block)
      after_work_cb = Callback.new(
          work_data_struct: ::LibStorj::Ext::Storj::JsonRequest,
          member_names: %i[error_code response handle],
          cast_map: {
              error_code: CURL_ERROR_CODE_CAST_PROC,
              response: JSON_C_CAST_METHOD,
              handle: handle_cast_proc
          }) do |req, error, response, callback|
        error = 'Failed to get info' if error.nil? && (response.nil? || response.empty?)

        callback.call error, response
      end.pointer

      reactor do |reactor|
        reactor.work do
          ::LibStorj::Ext::Storj.get_info @storj_env_ptr, handle, after_work_cb
        end
      end
    end

    def get_buckets(&block)
      handle_cast_proc = Proc.new do |handle|
        FFI::Function.new :void, %i[string string], handle
      end

      work_cb = Factory.error_response_callback(&block)
      after_work_cb = Callback.new(
          work_data_struct: ::LibStorj::Ext::Storj::GetBucketRequest,
          member_names: %i[error_code response handle],
          cast_map: {
              # response: LibStorj.method(:parse_json),
              error_code: CURL_ERROR_CODE_CAST_PROC,
              response: JSON_C_CAST_METHOD,
              handle: handle_cast_proc
          }) do |req, error, response, callback|
        error = 'Failed to get info' if error.nil? && (response.nil? || response.empty?)

        callback.call error, response
      end.pointer

      reactor do |reactor|
        reactor.work do
          ::LibStorj::Ext::Storj.get_buckets @storj_env_ptr, work_cb, after_work_cb
        end
      end
    end
  end
end
