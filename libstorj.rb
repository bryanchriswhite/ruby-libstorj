$:.unshift File.join(File.dirname(__FILE__), "..", "lib"), File.join(File.dirname(__FILE__), "..", "build", RUBY_VERSION) unless RUBY_PLATFORM =~ /java/
require 'rubygems'
require 'ffi'
#require 'spec'

module LibStorj
  extend FFI::Library
  ffi_lib ['libstorj']

  class StorjBridgeOptions_t < FFI::Struct
    layout :proto, :pointer,
           :host, :string,
           :port, :int,
           :user, :string,
           :pass, :string
  end

  class StorjEncryptOptions_t < FFI::Struct
    layout :mnemonic, :string
  end

  class StorjHttpOptions_t < FFI::Struct
    layout :user_agent, :string,
           :proxy_url, :string,
           :cainfo_path, :string,
           :low_speed_limit, :uint64,
           :low_speed_time, :uint64,
           :timeout, :uint64
  end

  class StorjLogOptions_t < FFI::Struct
    layout :user_agent, :string,
           :proxy_url, :string,
           :cainfo_path, :string,
           :low_speed_limit, :uint64,
           :low_speed_time, :uint64,
           :timeout, :uint64
  end
  # ffi_lib FFI::Library::LIBC
  # attach_function("cputs", "puts", [ :string ], :int)

  ### libstorj/src/storj.h:636-641
  #  /**
  # * @brief Will get the current unix timestamp in milliseconds
  # *
  # * @return A unix timestamp
  # */
  #  STORJ_API uint64_t storj_util_timestamp();


  ### node-libstorj/libstorj.cc:27-34
  #
  # void Timestamp(const v8::FunctionCallbackInfo<Value>& args) {
  #     Isolate* isolate = args.GetIsolate();
  #
  # uint64_t timestamp = storj_util_timestamp();
  # Local<Number> timestamp_local = Number::New(isolate, timestamp);
  #
  # args.GetReturnValue().Set(timestamp_local);
  # }storj_mnemonic_check', [:string], :bool)

  # callback :util_timestamp
  attach_function('util_timestamp', 'storj_util_timestamp', [], :int)
  attach_function('mnemonic_check', 'storj_mnemonic_check', [:string], :bool)
  attach_function('init_env', 'storj_init_env', [
      StorjBridgeOptions_t.by_ref,
      StorjEncryptOptions_t.by_ref,
      StorjHttpOptions_t.by_ref,
      StorjLogOptions_t.by_ref
  ], :pointer)

  def Environment(bridge_options, encrypt_options, http_options, log_options)

  end

end
