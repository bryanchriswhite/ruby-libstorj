module LibStorj
  module Ext
    module Storj
      extend FFI::Library
      ffi_lib('storj')

      attach_function('util_timestamp', 'storj_util_timestamp', [], :uint64)
      attach_function('mnemonic_check', 'storj_mnemonic_check', [:string], :bool)
    end
  end
end