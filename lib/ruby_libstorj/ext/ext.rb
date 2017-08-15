module LibStorj
  module Ext
    module Storj
      extend FFI::Library
      ffi_lib('storj')

      attach_function('get_info', 'storj_bridge_get_info', [
          Env.ptr,
          JSON_REQUEST_CALLBACK,
          :pointer # uv_after_work_cb*
      # ::LibStorj::UV::
      ], :int)

      attach_function('init_env', 'storj_init_env', [
          BridgeOptions.ptr,
          EncryptOptions.ptr,
          HttpOptions.ptr,
          LogOptions.ptr
      ], Env.ptr)

      module Misc
        extend FFI::Library
        ffi_lib('storj')

        attach_function('util_timestamp', 'storj_util_timestamp', [], :uint64)
        attach_function('mnemonic_check', 'storj_mnemonic_check', [:string], :bool)
      end
    end

    module JsonC
      extend FFI::Library
      ffi_lib('json-c')

      attach_function('parse_json', 'json_object_to_json_string', [:pointer], :string)
    end

    module Curl
      extend FFI::Library
      ffi_lib('curl')
      # attach_function('curl_error', 'curl_easy_strerror', [:pointer], :string)
    end

    module UV
      extend FFI::Library
      ffi_lib('uv')
    end
  end
end