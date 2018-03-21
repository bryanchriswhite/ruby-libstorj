module LibStorj
  module Storj
    module Mixins
      require 'yaml'

      def load_yaml_options(path)
        throw(:ENOENT) unless File.exist?(path)

        options_yml = YAML.load_file path
        build_options(default_type_map, options_yml.to_hash)
      end

      def default_type_map
        {
            bridge: ::LibStorj::Ext::Storj::BridgeOptions,
            encrypt: ::LibStorj::Ext::Storj::EncryptOptions,
            http: ::LibStorj::Ext::Storj::HttpOptions,
            log: ::LibStorj::Ext::Storj::LogOptions
        }
      end

      def build_options(type_map, option_groups)
        Hash[option_groups.map do |group_name, options|

          option_type = type_map[group_name.to_sym]
          member_field_hash = Hash[option_type.members.zip option_type.layout.fields]
          option_instance = option_type.new

          options.map do |name, value|
            name = name.to_sym

            if name == :logger
              option_instance[:logger] = ::LibStorj::Ext::Storj.const_get value

              next
            end

            option_field = member_field_hash[name]

            # TODO: check types and/or error handle
            if option_field.nil?
              option_instance = FFI::MemoryPointer::NULL
            elsif option_field.is_a?(FFI::StructLayout::Pointer)
              # Assuming pointers are strings
              #
              pointer = FFI::MemoryPointer.from_string(value.nil? ? '' : value)
              option_instance[name] = pointer
            else
              option_instance[name] = value
            end

          end

          [group_name, option_instance]
        end]
      end
    end
  end

  module Ext
    module Storj
      module Mixins
        def util_timestamp
          ::LibStorj::Ext::Storj.util_timestamp
        end

        def util_datetime
          # '%Q' - Number of milliseconds since 1970-01-01 00:00:00 UTC.
          DateTime.strptime(::LibStorj::Ext::Storj.util_timestamp.to_s, '%Q')
        end

        def mnemonic_check(mnemonic)
          ::LibStorj::Ext::Storj.mnemonic_check(mnemonic)
        end

        # default to highest strength; strength range: (128..256)
        def mnemonic_generate(strength = 256)
          pointer = FFI::MemoryPointer.new :pointer, 1
          ::LibStorj::Ext::Storj.mnemonic_generate(strength, pointer)
          pointer.read_pointer.read_string
        end
      end
    end
  end
end
