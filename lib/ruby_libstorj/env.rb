module LibStorj
  class Env
    require 'libuv'

    attr_reader :storj_env_ptr

    def initialize(*options)
      @storj_env_ptr = ::LibStorj::Ext::Storj.method(:init_env).call(*options)
      @storj_env_ptr[:loop] = ::Libuv::Ext.default_loop
    end

    def get_info(&block)
      callback = LibStorj::Factory.json_response_callback(&block)
      reactor_ext_proxy callback, ::LibStorj::Ext::Storj, :get_info
    end

    def get_buckets(&block)
      callback = LibStorj::Factory.json_response_callback(&block)
      reactor_ext_proxy callback, ::LibStorj::Ext::Storj, :get_buckets
    end

    private

    def reactor_ext_proxy(callback, ext_module, method_name)
      reactor do |reactor|
        reactor.work do
          ext_module.send(
              method_name,
              storj_env_ptr,
              callback,
              CALLBACKS[method_name]
          )
        end
      end
    end
  end
end
