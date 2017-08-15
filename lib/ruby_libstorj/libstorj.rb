$:.unshift File.join(File.dirname(__FILE__), "..", "lib"), File.join(File.dirname(__FILE__), "..", "build", RUBY_VERSION) unless RUBY_PLATFORM =~ /java/
require 'rubygems'
require 'ffi'
require 'date'

module LibStorj
  require 'ruby_libstorj/ext/types'
  require 'ruby_libstorj/ext/ext'

  require 'ruby_libstorj/env'

  include ::LibStorj::Ext::Storj::Public

  def self.util_datetime
    # '%Q' - Number of milliseconds since 1970-01-01 00:00:00 UTC.
    DateTime.strptime(::LibStorj::Ext::Storj.util_timestamp.to_s, '%Q')
  end

  class FFI::Struct
    # allows for destructuring. NB: `values_at` members array order
    #   must match assignment order!
    #
    # options hash:
    #   - :json, an array of symbols for which respective layout
    #            members will be passed through `json_parse`
    #
    # example: ```
    #       log_options = StorjLogOptions_t.new(...)
    #       logger, level = log_options.values_at(members: [:logger, :level])
    #       ```

    def values_at(options: {}, members:)
      if options[:json].nil?
        members.map {|member_name| self[member_name]} if options[:json].nil?
      else
        members.map do |member_name|
          value = self[member_name]
          if value.is_a?(FFI::Pointer) &&
              value != FFI::MemoryPointer::NULL &&
              options[:json].include?(member_name)
            # just return the pointer if this raises an exception
            begin
              next ::LibStorj::Ext::JsonC.parse_json(value)
            rescue #=> e
              # TODO: better error handling
              # binding.pry
              next value
            end
          end

          value
        end
      end
    end

    # convenience method for inspecting struct hierarchies
    def map_layout
      # NB: Hash[ [ [key, value], ... ] ] → new_hash
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
end
