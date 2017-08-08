$:.unshift File.join(File.dirname(__FILE__), "..", "lib"), File.join(File.dirname(__FILE__), "..", "build", RUBY_VERSION) unless RUBY_PLATFORM =~ /java/
require 'rubygems'
require 'ffi'
require 'date'
### NB: (build with `ruby ./extconf.rb && make` in project root)
require './ruby_libstorj' #-- refers to ./ruby_libstorj.so

module LibStorjRuby
  STORJ_LOW_SPEED_LIMIT = 30720
  STORJ_LOW_SPEED_TIME = 20
  STORJ_HTTP_TIMEOUT = 60

  extend FFI::Library
  POINTER = FFI::MemoryPointer
  # ffi_lib "#{__dir__}/ruby_libstorj.so", 'storj'
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

  # class StorjLoggerFn_t < FFI::Struct
  #   layout :options, StorjLogLevels_t,
  #   # typedef void (*storj_logger_format_fn)(storj_log_options_t *options,
  #   #                                        void *handle,
  #   #                                        const char *format, ...);
  # end

  # attach_function('logger_format_fn', 'storj_logger_format_fn', [:string], :void)
  #
  # class StorjLogLevels_t < FFI::Struct
  #   layout :debug, LibStorj.logger_format_fn('debug'),
  #          :info, LibStorj.logger_format_fn('info'),
  #          :warn, LibStorj.logger_format_fn('warn'),
  #          :error, LibStorj.logger_format_fn('error')

  #  # typedef struct storj_log_levels {
  #  #   storj_logger_format_fn debug;
  #  #   storj_logger_format_fn info;
  #  #   storj_logger_format_fn warn;
  #  #   storj_logger_format_fn error;
  #  # } storj_log_levels_t;
  # end

  class StorjEnv_t < FFI::Struct
    # layout :storj_bridge_options, StorjBridgeOptions_t.ptr,
    #        :storj_encrypt_options, StorjEncryptOptions_t.ptr,
    #        :storj_http_options, StorjHttpOptions_t.ptr,
    #        :storj_log_options, StorjLogOptions_t.ptr,
    layout :storj_bridge_options, :pointer,
           :storj_encrypt_options, :pointer,
           :storj_http_options, :pointer,
           :storj_log_options, :pointer,
           :tmp_path, :pointer, # char*
           :loop, :pointer, # uv_loop_t*
           :log, :pointer # storj_log_levels_t*
  end

  attach_function('util_timestamp', 'storj_util_timestamp', [], :uint64)
  attach_function('mnemonic_check', 'storj_mnemonic_check', [:string], :bool)
  # attach_function('init_env', 'storj_init_env', [
  #     StorjBridgeOptions_t.ptr,
  #     StorjEncryptOptions_t.ptr,
  #     StorjHttpOptions_t.ptr,
  #     StorjLogOptions_t.ptr
  # ], :pointer)
  attach_function('init_env', 'storj_init_env', [
      StorjBridgeOptions_t.ptr,
      StorjEncryptOptions_t.ptr,
      StorjHttpOptions_t.ptr,
      StorjLogOptions_t.ptr
  ], StorjEnv_t.ptr)

  def self.util_datetime
    # '%Q' - Number of milliseconds since 1970-01-01 00:00:00 UTC.
    DateTime.strptime(util_timestamp.to_s, '%Q')
  end

  def self.string_to_pointer(str)
    FFI::MemoryPointer.from_string(str)
  end

  def self.init_test(username, password)
    bridge = StorjBridgeOptions_t.new
    encrypt = StorjEncryptOptions_t.new
    http = StorjHttpOptions_t.new
    log = StorjLogOptions_t.new

    bridge[:proto] = string_to_pointer 'https'
    bridge[:port] = 443
    bridge[:host] = string_to_pointer 'api.storj.io'
    bridge[:user] = string_to_pointer username
    bridge[:pass] = string_to_pointer password

    encrypt[:mnemonic] = string_to_pointer('one two three four five six seven')

    http[:user_agent] = string_to_pointer('storj-test')
    http[:proxy_url] = nil
    http[:cainfo_path] = nil
    http[:low_speed_limit] = STORJ_LOW_SPEED_LIMIT
    http[:low_speed_limit] = STORJ_LOW_SPEED_TIME
    http[:timeout] = STORJ_HTTP_TIMEOUT

    log[:logger] = nil
    log[:level] = 0

    init_env(bridge, encrypt, http, log)
  end


  # class Environment(bridge_options, encrypt_options, http_options, log_options)
  #
  # end

end
