module LibStorj
  module Factory
    def self.error_response_callback(&block)
      FFI::Function.new(:void, %i[string string], &block)
    end
  end
end
