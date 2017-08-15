module LibStorj
  class Env
    require 'libuv'

    def initialize(*options)
      @storj_env_ptr = ::LibStorj::Ext::Storj.method(:init_env).call(*options)
      @storj_env_ptr[:loop] = ::Libuv::Ext.default_loop
    end

    def get_info(&block)
      handle = FFI::Function.new(:void, [:string, :string], &block)

      get_info_callback = FFI::Function.new(:void, [::LibStorj::Ext::UV::UVWork.ptr, :int]) do |work_req, status|
        error_code, status_code, body, response = work_req[:data].values_at(
            options: {json: %i[body response]},
            members: %i[error_code status_code body response handle]
        )

        # begin
        error = nil
        if !error_code.nil? || (response == 'null' || response == POINTER::NULL)
          error = error_code ? "wip error w/ code: #{error_code}" : 'wip error'
        end

        # TODO: remove me
        require 'pp'
        pp work_req.map_layout

        handle.call error, response
        # rescue => e
        #   binding.pry
        # end
      end

      reactor do |reactor|
        reactor.work {
          ::LibStorj::Ext::Storj.get_info @storj_env_ptr, handle, get_info_callback
        }
      end
    end
  end
end
