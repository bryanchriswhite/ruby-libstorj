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

      attach_function('stringify', 'json_object_to_json_string', [:pointer], :string)
      attach_function('parse', 'json_tokener_parse', [:string], :pointer)
    end

    module Storj
      extend FFI::Library
      ffi_lib('storj')

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

      attach_function('create_bucket', 'storj_bridge_create_bucket', [
          Env.ptr,
          :string,
          JSON_REQUEST_CALLBACK,
          :pointer # uv_after_work_cb*
      # ::LibStorj::UV::
      ], :int)

      attach_function('delete_bucket', 'storj_bridge_delete_bucket', [
          Env.ptr,
          :string,
          JSON_REQUEST_CALLBACK,
          :pointer # uv_after_work_cb*
      # ::LibStorj::UV::
      ], :int)

      attach_function('destroy_env', 'storj_destroy_env', [
          Env.ptr
      ], :int)

      attach_function('init_env', 'storj_init_env', [
          BridgeOptions.ptr,
          EncryptOptions.ptr,
          HttpOptions.ptr,
          LogOptions.ptr
      ], Env.ptr)

      class Bucket < FFI::Struct
        attr_reader :name, :id

        def initialize(*args)
          super(*args)

          @name = self[:name]
          @id = self[:id]
        end

        def self.pointer_to_array(pointer, array_length)
          if pointer.nil? || pointer == FFI::MemoryPointer::NULL || array_length < 1
            return nil
          end

          ### #=> [#<LibStorj::Ext::Storj::Bucket ...>, ...]
          (0..(array_length - 1)).map do |i|
            Bucket.new pointer[i * size]
          end
        end
      end
    end

    module UV
      extend FFI::Library
      ffi_lib('uv')
    end
  end
end