module LibStorj
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

    def values_at(*members)
      members.map {|member_name| self[member_name]}
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
