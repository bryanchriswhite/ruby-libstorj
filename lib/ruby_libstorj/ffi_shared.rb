require 'rubygems'
require 'ffi'

module LibStorj
  module FFIShared
    CLIBS = [
        'c',
        'json-c',
        'curl',
        'uv',
        'storj',
        ### NB: (build with `ruby ./extconf.rb && make` in project root)
        "#{__dir__}/ruby_libstorj.so"
    ].freeze

    def self.included(base)
      base.send :extend, FFI::Library
      base.ffi_lib(*CLIBS)
    end

    # apply `extend FFI::Library`, etc. to self
    # included(self)

    # class Curl
    #   include FFIShared
    # end

    # attach_function('parse_json', 'json_object_to_json_string', [:pointer], :string)

    # STORJ_LOW_SPEED_LIMIT = 30720
    # STORJ_LOW_SPEED_TIME = 20
    # STORJ_HTTP_TIMEOUT = 60
    #
    # POINTER = FFI::MemoryPointer

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

    # class StorjBridgeOptions_t < FFI::Struct
    #   layout :proto, :pointer,
    #          :host, :pointer,
    #          :port, :int,
    #          :user, :pointer,
    #          :pass, :pointer
    # end
    #
    # class StorjEncryptOptions_t < FFI::Struct
    #   layout :mnemonic, :pointer
    # end
    #
    # class StorjHttpOptions_t < FFI::Struct
    #   layout :user_agent, :pointer,
    #          :proxy_url, :pointer,
    #          :cainfo_path, :pointer,
    #          :low_speed_limit, :long,
    #          :low_speed_time, :long,
    #          :timeout, :long
    # end
    #
    # class StorjLogOptions_t < FFI::Struct
    #   layout :logger, :pointer,
    #          :level, :int
    # end
    #
    # Handle = callback :handle, [:string, :string], :void
    #
    # class JsonRequest_t < FFI::Struct
    #   layout :http_options, StorjHttpOptions_t.ptr,
    #          :options, StorjBridgeOptions_t.ptr,
    #          :method, :string,
    #          :path, :string,
    #          :auth, :bool,
    #          :body, :pointer, # struct json_object *body;
    #          :response, :pointer, # struct json_object *response;
    #          :error_code, :int,
    #          :status_code, :int,
    #          :handle, Handle
    # end
    #
    # enum :uv_work_req, [
    #     :UV_UNKNOWN_REQ, 0,
    #     :UV_REQ,
    #     :UV_CONNECT,
    #     :UV_WRITE,
    #     :UV_SHUTDOWN,
    #     :UV_UDP_SEND,
    #     :UV_FS,
    #     :UV_WORK,
    #     :UV_GETADDRINFO,
    #     :UV_GETNAMEINFO,
    #     :UV_REQ_TYPE_PRIVATE,
    #     :UV_REQ_TYPE_MAX,
    # ]
    #
    # class UVWork_t < FFI::Struct
    #   layout :data, JsonRequest_t.ptr,
    #          # /* read-only */                                                             \
    #          :type, :uv_work_req,
    #          # /* private */                                                               \
    #          :active_queue, :pointer,
    #          :reserved, :pointer,
    #          :loop, :pointer,
    #          :work_cb, :pointer,
    #          :after_work_cb, :pointer
    #
    #   # void* active_queue[2];                                                      \
    #   # void* reserved[4];                                                          \
    #   # ...
    #   #   UV_WORK_PRIVATE_FIELDS
    #   # };
    # end
    #
    #
    # class StorjEnv_t < FFI::Struct
    #   layout :storj_bridge_options, StorjBridgeOptions_t.ptr,
    #          :storj_encrypt_options, StorjEncryptOptions_t.ptr,
    #          :storj_http_options, StorjHttpOptions_t.ptr,
    #          :storj_log_options, StorjLogOptions_t.ptr,
    #          :tmp_path, :pointer,
    #          :loop, :pointer, # uv_loop_t*
    #          :log, :pointer # storj_log_levels_t*
    # end
  end
end