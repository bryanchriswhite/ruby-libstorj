require 'rubygems'
require 'ffi'

module FFIShared
  # module FFILibraryWrapper
  #   extend FFI::Library
  #   METHODS = %i[
  #     attach_function
  #     ffi_lib
  #   ].freeze
  # end

  def self.included(base)
    # FFILibraryWrapper::METHODS.each do |method|
    #   base.define_singleton_method method, FFILibraryWrapper.method(method)
    # end

    base.send :extend, FFI::Library
    base.ffi_lib 'storj', "#{__dir__}/ruby_libstorj.so"
  end

  STORJ_LOW_SPEED_LIMIT = 30720
  STORJ_LOW_SPEED_TIME = 20
  STORJ_HTTP_TIMEOUT = 60

  POINTER = FFI::MemoryPointer

  # extend SharedLibs
  ### NB: (build with `ruby ./extconf.rb && make` in project root)
  # ffi_lib "#{__dir__}/ruby_libstorj.so", 'storj'

  class StorjBridgeOptions_t < FFI::Struct
    layout :proto, :pointer,
           :host, :pointer,
           :port, :int,
           :user, :pointer,
           :pass, :pointer
  end

  class StorjEncryptOptions_t < FFI::Struct
    layout :mnemonic, :pointer
  end

  class StorjHttpOptions_t < FFI::Struct
    layout :user_agent, :pointer,
           :proxy_url, :pointer,
           :cainfo_path, :pointer,
           :low_speed_limit, :long,
           :low_speed_time, :long,
           :timeout, :long
  end

  class StorjLogOptions_t < FFI::Struct
    layout :logger, :pointer,
           :level, :int
  end

  class StorjEnv_t < FFI::Struct
    layout :storj_bridge_options, StorjBridgeOptions_t.ptr,
           :storj_encrypt_options, StorjEncryptOptions_t.ptr,
           :storj_http_options, StorjHttpOptions_t.ptr,
           :storj_log_options, StorjLogOptions_t.ptr,
           :tmp_path, :pointer, # char*
           :loop, :pointer, # uv_loop_t*
           :log, :pointer # storj_log_levels_t*
  end
end