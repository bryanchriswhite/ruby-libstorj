require 'yaml'
require 'ruby_libstorj'

def build_options(type_map)
  options_yml = YAML.load_file "#{__dir__}/options.yml"
  options_yml.to_a.map do |option_group|
    group_name, options = option_group

    option_type = type_map[group_name.to_sym]
    member_field_hash = Hash[option_type.members.zip option_type.layout.fields]
    option_instance = option_type.new

    options.each do |option|
      name, value = [option[0].to_sym, option[1]]

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

    option_instance
  end
end

def default_options
  build_options bridge: ::LibStorj::Ext::Storj::BridgeOptions,
                encrypt: ::LibStorj::Ext::Storj::EncryptOptions,
                http: ::LibStorj::Ext::Storj::HttpOptions,
                log: ::LibStorj::Ext::Storj::LogOptions
end

