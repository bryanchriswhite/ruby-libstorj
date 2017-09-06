module LibStorj
  module Ext
    module Curl
      extend FFI::Library
      ffi_lib('curl')

      attach_function('easy_stderr', 'curl_easy_strerror', [:curl_code], :string)

      def self.curl_code_to_string(error_code)
        return nil if error_code.nil?

        curl_error = ::LibStorj::Ext::Curl.easy_stderr(error_code)
        error_code > 0 ? curl_error : ''
      end
    end

    module JsonC
      extend FFI::Library
      ffi_lib('json-c')

      attach_function('stringify', 'json_object_to_json_string', [:pointer], :string)
      attach_function('parse', 'json_tokener_parse', [:string], :pointer)
    end

    module Storj
      extend FFI::Library
      ffi_lib('storj')

      attach_function('mnemonic_generate', 'storj_mnemonic_generate', [:int, :pointer], :int)

      attach_function('get_info', 'storj_bridge_get_info', [
          Env.by_ref,
          ::LibStorj::Ext::Storj::JsonRequest::CALLBACK,
          :pointer # uv_after_work_cb*
      # ::LibStorj::UV::
      ], :int)

      attach_function('destroy_env', 'storj_destroy_env', [
          Env.by_ref
      ], :int)

      attach_function('init_env', 'storj_init_env', [
          BridgeOptions.by_ref,
          EncryptOptions.by_ref,
          HttpOptions.by_ref,
          LogOptions.by_ref
      ], Env.by_ref)
    end

    module UV
      extend FFI::Library
      ffi_lib('uv')
    end
  end
end