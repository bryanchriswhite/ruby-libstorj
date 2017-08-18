module LibStorj
  module Ext
    module Curl
      extend FFI::Library
      ffi_lib('curl')

      attach_function('easy_stderr', 'curl_easy_strerror', [:curl_code], :string)
    end

    module JsonC
      extend FFI::Library
      ffi_lib('json-c')

      attach_function('parse_json', 'json_object_to_json_string', [:pointer], :string)
    end

    module Storj
      extend FFI::Library
      ffi_lib('storj')

      attach_function('mnemonic_generate', 'storj_mnemonic_check', [:int, :pointer], :int)

      attach_function('get_info', 'storj_bridge_get_info', [
          Env.ptr,
          JSON_REQUEST_CALLBACK,
          :pointer # uv_after_work_cb*
      # ::LibStorj::UV::
      ], :int)

      attach_function('get_buckets', 'storj_bridge_get_buckets', [
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
    end

    module UV
      extend FFI::Library
      ffi_lib('uv')
    end
  end
end