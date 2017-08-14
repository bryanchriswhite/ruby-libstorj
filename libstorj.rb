$:.unshift File.join(File.dirname(__FILE__), "..", "lib"), File.join(File.dirname(__FILE__), "..", "build", RUBY_VERSION) unless RUBY_PLATFORM =~ /java/
require 'rubygems'
require 'ffi'
require 'date'
require_relative './ffi_shared'

module LibStorj
  include FFIShared

  # convenience method for inspecting struct hierarchies
  class FFI::Struct
    # allows for destructuring. NB: `values_at` members array order
    #   must match assignment order!
    #
    # example: ```
    #       log_options = StorjLogOptions_t.new(...)
    #       logger, level = log_options.values_at members: [:logger, :level])
    #       ```
    def values_at(options: {}, members:)
      if options[:json].nil?
        members.map {|member_name| self[member_name]} if options[:json].nil?
      else
        members.map do |member_name|
          value = self[member_name]
          if options[:json].include?(member_name)
            next LibStorj.parse_json(value)
          end

          value
        end
      end
    end

    def map_layout
      Hash[members.map do |member_name|
        member = self[member_name]
        value = member.is_a?(FFI::Struct) ? member.map_layout : member
        if value.is_a? FFI::Pointer
          next [member_name, nil] if value == FFI::MemoryPointer::NULL

          # attempt to read as string
          begin
            string_value = value.read_string
            # update value to string_value if it contains only printable characters
            if string_value =~ /^[[:print:]]*$/
              value = string_value
            end
          rescue
          end

        end
        [member_name, value]
      end]
    end
  end

  # attach_function('curl_error', 'curl_easy_strerror', [:pointer], :string)

  attach_function('util_timestamp', 'storj_util_timestamp', [], :uint64)
  attach_function('mnemonic_check', 'storj_mnemonic_check', [:string], :bool)

  attach_function('get_info', 'storj_bridge_get_info', [
      LibStorj::StorjEnv_t.ptr,
      Handle,
      :pointer
  ], :int)

  def self.init_env(*options)
    self.method(:_init_env).call(*options)
  end

  attach_function('_init_env', 'init_storj_ruby', [
      StorjBridgeOptions_t.ptr,
      StorjEncryptOptions_t.ptr,
      StorjHttpOptions_t.ptr,
      StorjLogOptions_t.ptr
  ], StorjEnv_t.ptr)
  private_class_method :_init_env

  def self.util_datetime
    # '%Q' - Number of milliseconds since 1970-01-01 00:00:00 UTC.
    DateTime.strptime(util_timestamp.to_s, '%Q')
  end

end
