module LibStorj
  module Ext
    module Storj
      class File < FFI::Struct
        extend FFI::Library
        ffi_lib('storj')

        def self.all(*args)
          _all(*args)
        end

        def self.pointer_to_array(pointer, array_length)
          if pointer.nil? || pointer == FFI::MemoryPointer::NULL || array_length < 1
            return nil
          end

          ### #=> [#<LibStorj::Ext::Storj::Bucket ...>, ...]
          (0..(array_length - 1)).map do |i|
            File.new pointer[i * size]
          end
        end

        attach_function('_all', 'storj_bridge_list_files', [
            Env.by_ref,
            :string,
            ::LibStorj::Ext::Storj::JsonRequest::CALLBACK,
            :pointer # uv_after_work_cb*
        # ::LibStorj::UV::
        ], :int)

        private :_all
      end
    end
  end
end