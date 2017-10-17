module LibStorj
  module Ext
    # NB: Ruby's ffi doesn't allow assigning to :string' pointer
    #     types.
    #
    #     You can use `FFI::MemoryPointer.from_string` to create a
    #     string pointer from a ruby string. Or use the
    #     `FFI::Pointer#write_string` method to update an existing
    #     string (or generic) pointer; see below
    #
    # NB: All pointer types use have
    #       `read_<type> (FFI::Pointer#read_<type>)`
    #                 and
    #       `write_<type> (FFI::Pointer#write_<type>)`
    #     methods to read and write respectively

    module Curl
      extend FFI::Library
      require 'ruby-libstorj/ext/curl_code'

      enum(:curl_code, CURL_CODES)
    end

    module Storj
      extend FFI::Library

      class BridgeOptions < FFI::Struct
        layout :proto, :pointer,
               :host, :pointer,
               :port, :int,
               :user, :pointer,
               :pass, :pointer
      end

      class Bucket < FFI::Struct
        layout :created, :string,
               :name, :string,
               :id, :string,
               :decrypted, :bool
      end

      class File < FFI::Struct
        layout :created, :string,
               :filename, :string,
               :mimetype, :string,
               :erasure, :string,
               :size, :uint64,
               :hmac, :string,
               :id, :string,
               :decrypted, :bool,
               :index, :string
      end

      class EncryptOptions < FFI::Struct
        layout :mnemonic, :pointer
      end

      class HttpOptions < FFI::Struct
        layout :user_agent, :pointer,
               :proxy_url, :pointer,
               :cainfo_path, :pointer,
               :low_speed_limit, :long,
               :low_speed_time, :long,
               :timeout, :long
      end

      class LogOptions < FFI::Struct
        layout :logger, :pointer,
               :level, :int
      end

      class Env < FFI::Struct
        layout :bridge_options, BridgeOptions.by_ref,
               :encrypt_options, EncryptOptions.by_ref,
               :http_options, HttpOptions.by_ref,
               :log_options, LogOptions.by_ref,
               :tmp_path, :pointer,
               :loop, :pointer, # uv_loop_t*
               :log, :pointer # storj_log_levels_t*
      end
    end

    module UV
      extend FFI::Library

      enum :uv_work_req, [
          :UV_UNKNOWN_REQ, 0,
          :UV_REQ,
          :UV_CONNECT,
          :UV_WRITE,
          :UV_SHUTDOWN,
          :UV_UDP_SEND,
          :UV_FS,
          :UV_WORK,
          :UV_GETADDRINFO,
          :UV_GETNAMEINFO,
          :UV_REQ_TYPE_PRIVATE,
          :UV_REQ_TYPE_MAX
      ]

      class Work < FFI::Struct
        layout :data, :pointer, # void*
               # read-only
               :type, :uv_work_req,
               # private
               :active_queue, :pointer,
               :reserved, :pointer,
               :loop, :pointer,
               :work_cb, :pointer,
               :after_work_cb, :pointer

        # void* active_queue[2];
        # void* reserved[4];
        # ...
        #   UV_WORK_PRIVATE_FIELDS
        # };
      end
    end

  end
end
