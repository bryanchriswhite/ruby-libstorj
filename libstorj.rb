$:.unshift File.join(File.dirname(__FILE__), "..", "lib"), File.join(File.dirname(__FILE__), "..", "build", RUBY_VERSION) unless RUBY_PLATFORM =~ /java/
require 'rubygems'
require 'ffi'
require 'date'
#require 'spec'

module LibStorj
  extend FFI::Library
  ffi_lib ['libstorj']

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
           :low_speed_limit, :uint64,
           :low_speed_time, :uint64,
           :timeout, :uint64
  end

  class StorjLogOptions_t < FFI::Struct
    layout :logger, :pointer,
           :level, :int
  end

  ### libstorj/src/storj.h:636-641
  #  /**
  # * @brief Will get the current unix timestamp in milliseconds
  # *
  # * @return A unix timestamp
  # */
  #  STORJ_API uint64_t storj_util_timestamp();

  attach_function('util_timestamp', 'storj_util_timestamp', [], :uint64)

  ### libstorj/src/storj.h:655-664
  #  /**
  # * @brief Will check that a mnemonic is valid
  # *
  # * This will check that a mnemonic has been entered correctly by verifying
  # * the checksum, and that words are a part of the list.
  # *
  # * @param[in] strength - The bits of entropy
  # * @return Will return true on success and false failure
  # */
  #  STORJ_API bool storj_mnemonic_check(const char *mnemonic);

  attach_function('mnemonic_check', 'storj_mnemonic_check', [:string], :bool)

  ### libstorj/src/storj.h:528-544
  #  /**
  # * @brief Initialize a Storj environment
  # *
  # * This will setup an event loop for queueing further actions, as well
  # * as define necessary configuration options for communicating with Storj
  # * bridge, and for encrypting/decrypting files.
  #      *
  #  * @param[in] options - Storj Bridge API options
  #  * @param[in] encrypt_options - File encryption options
  #  * @param[in] http_options - HTTP settings
  #  * @param[in] log_options - Logging settings
  #  * @return A null value on error, otherwise a storj_env pointer.
  #  */
  #
  #  STORJ_API storj_env_t *storj_init_env(storj_bridge_options_t *options,
  #                                        storj_encrypt_options_t *encrypt_options,
  #                                        storj_http_options_t *http_options,
  #                                        storj_log_options_t *log_options);

  attach_function('init_env', 'storj_init_env', [
      StorjBridgeOptions_t.by_ref,
      StorjEncryptOptions_t.by_ref,
      StorjHttpOptions_t.by_ref,
      StorjLogOptions_t.by_ref
  ], :uint64)

  def util_datetime
    # '%Q' - Number of milliseconds since 1970-01-01 00:00:00 UTC.
    DateTime.strptime(util_timestamp.to_s, '%Q')
  end

  # def Environment(bridge_options, encrypt_options, http_options, log_options)
  #
  # end

end
