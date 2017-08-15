module LibStorj
  module Factory
    def self.callback(method_name, *member_names, &block)
      FFI::Function.new(
          :void, [::LibStorj::Ext::UV::Work.ptr, :int]
      ) do |json_request_pointer, uv_status|
        req = json_request_pointer[:data]

        member_values = req.values_at member_names.flatten

        puts "yielding...; member_values: #{member_values}"
        yield req, *member_values
      end
    end

    def self.json_response_callback(&block)
      FFI::Function.new(:void, %i[string string], &block)
    end
  end
end
