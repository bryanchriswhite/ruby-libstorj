module LibStorj
  class Env
    require 'libuv'

    def initialize(*options)
      @storj_env_ptr = ::LibStorj::Ext::Storj.method(:init_env).call(*options)
      @storj_env_ptr[:loop] = ::Libuv::Ext.default_loop
    end

    def get_info(&block)
      handle = FFI::Function.new(:void, %i[string string], &block)

      get_info_callback = FFI::Function.new(:void, [::LibStorj::Ext::UV::UVWork.ptr, :int]) do |work_req, _status|
        error_code, response = work_req[:data].values_at(
            options: {json: %i[response]},
            members: %i[error_code response handle]
        )

        # begin
        error = nil
        if !error_code.nil? || (response == 'null' || response == FFI::MemoryPointer::NULL)
          error = if !error_code.nil?
                    ::LibStorj::Ext::Curl.easy_stderr(error_code)
                  else
                    'Failed to get info'
                  end

          response = 'null' if response == FFI::MemoryPointer::NULL
        end


        handle.call error, response
        # TODO: better error handling
        # rescue #=> e
        #   binding.pry
        # end
      end

      reactor do |reactor|
        reactor.work do
          ::LibStorj::Ext::Storj.get_info @storj_env_ptr, handle, get_info_callback
        end
      end
    end
  end
end
