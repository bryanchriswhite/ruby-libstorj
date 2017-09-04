module LibStorj
  module Ext
    module Storj
      class Bucket < FFI::Struct
        extend FFI::Library
        ffi_lib('storj')

        attr_reader :name, :id

        def initialize(*args)
          super(*args)

          @name = self[:name]
          @id = self[:id]
        end

        def self.all(*args)
          _all(*args)
        end

        def self.create(*args)
          _create(*args)
        end

        def self.delete(*args)
          _delete(*args)
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

        attach_function('_all', 'storj_bridge_get_buckets', [
            Env.by_ref,
            ::LibStorj::Ext::Storj::JsonRequest::CALLBACK,
            :pointer # uv_after_work_cb*
        # ::LibStorj::UV::
        ], :int)

        private :_all

        attach_function('_create', 'storj_bridge_create_bucket', [
            Env.by_ref,
            :string,
            ::LibStorj::Ext::Storj::JsonRequest::CALLBACK,
            :pointer # uv_after_work_cb*
        # ::LibStorj::UV::
        ], :int)

        private :_create

        attach_function('_delete', 'storj_bridge_delete_bucket', [
            Env.by_ref,
            :string,
            ::LibStorj::Ext::Storj::JsonRequest::CALLBACK,
            :pointer # uv_after_work_cb*
        # ::LibStorj::UV::
        ], :int)

        private :_delete
      end
    end
  end
end