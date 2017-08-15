module LibStorj
  class Env
    require 'libuv'

    def initialize(*options)
      @storj_env_ptr = ::LibStorj::Ext::Storj.method(:init_env).call(*options)
      @storj_env_ptr[:loop] = ::Libuv::Ext.default_loop
    end

    def get_info(&block)
      handle = FFI::Function.new(:void, %i[string string], &block)


      reactor do |reactor|
        reactor.work do
          ::LibStorj::Ext::Storj.get_info @storj_env_ptr, handle, get_info_callback
        end
      end
    end

    private

    # returns an `FFI::Function`
    def get_info_callback
      FFI::Function.new(
          :void, [::LibStorj::Ext::UV::UVWork.ptr, :int]
      ) do |json_request_pointer, _status|
        error_code,
        response_pointer,
        handle = json_request_pointer[:data].values_at(
            :error_code,
            :response,
            :handle
        )

        response = LibStorj.parse_json(response_pointer)
        error = if !error_code.nil?
                  ::LibStorj::Ext::Curl.easy_stderr(error_code)
                elsif response.nil?
                  'Failed to get info'
                end

        handle.call error, response
      end
    end
  end
end
