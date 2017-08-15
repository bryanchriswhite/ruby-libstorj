require 'ruby-libstorj/ext/types'

module LibStorj
  module Ext
    module Storj
      include ::LibStorj::FFIShared

      attach_function('util_timestamp', 'storj_util_timestamp', [], :uint64)
      attach_function('mnemonic_check', 'storj_mnemonic_check', [:string], :bool)

      attach_function('get_info', 'storj_bridge_get_info', [
          Env.ptr,
          JSON_REQUEST_CALLBACK,
          :pointer # uv_after_work_cb*
          # ::LibStorj::UV::
      ], :int)
    end

    module Json
      include ::LibStorj::FFIShared

      attach_function('parse_json', 'json_object_to_json_string', [:pointer], :string)
    end
  end
end