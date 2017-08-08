$:.unshift File.join(File.dirname(__FILE__), "..", "lib"), File.join(File.dirname(__FILE__), "..", "build", RUBY_VERSION) unless RUBY_PLATFORM =~ /java/
require 'rubygems'
require 'ffi'
require 'date'

module LibStorj
  STORJ_LOW_SPEED_LIMIT = 30720
  STORJ_LOW_SPEED_TIME = 20
  STORJ_HTTP_TIMEOUT = 60

  extend FFI::Library
  POINTER = FFI::MemoryPointer
  ### NB: (build with `ruby ./extconf.rb && make` in project root)
  ffi_lib "#{__dir__}/ruby_libstorj.so", 'storj'

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

  attach_function('util_timestamp', 'storj_util_timestamp', [], :uint64)
  attach_function('mnemonic_check', 'storj_mnemonic_check', [:string], :bool)
  attach_function('init_env', 'init_storj_ruby', [
      StorjBridgeOptions_t.ptr,
      StorjEncryptOptions_t.ptr,
      StorjHttpOptions_t.ptr,
      StorjLogOptions_t.ptr
  ], StorjEnv_t.ptr)

  def self.util_datetime
    # '%Q' - Number of milliseconds since 1970-01-01 00:00:00 UTC.
    DateTime.strptime(util_timestamp.to_s, '%Q')
  end
end
