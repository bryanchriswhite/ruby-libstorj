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

      require 'ruby_libstorj/ext/curl_code'

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

      JSON_REQUEST_CALLBACK = callback [:string, :string], :void

      class JsonRequest_t < FFI::Struct
        layout :http_options, HttpOptions.ptr,
               :options, BridgeOptions.ptr,
               :method, :string,
               :path, :string,
               :auth, :bool,
               :body, :pointer, # struct json_object *body;
               :response, :pointer, # struct json_object *response;
               :error_code, :int,
               :status_code, :int,
               :handle, JSON_REQUEST_CALLBACK
      end

      class Env < FFI::Struct
        layout :storj_bridge_options, BridgeOptions.ptr,
               :storj_encrypt_options, EncryptOptions.ptr,
               :storj_http_options, HttpOptions.ptr,
               :storj_log_options, LogOptions.ptr,
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
        layout :data, Ext::Storj::JsonRequest_t.ptr,
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