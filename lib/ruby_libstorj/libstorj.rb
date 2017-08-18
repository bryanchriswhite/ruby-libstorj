require 'rubygems'
require 'ffi'
require 'date'

module LibStorj
  require 'ruby_libstorj/struct'
  require 'ruby_libstorj/ext/types'
  require 'ruby_libstorj/ext/ext'

  require 'ruby_libstorj/env'
  require 'ruby_libstorj/mixins/storj'

  extend ::LibStorj::Ext::Storj::Mixins

  def self.util_datetime
    # '%Q' - Number of milliseconds since 1970-01-01 00:00:00 UTC.
    DateTime.strptime(LibStorj.util_timestamp.to_s, '%Q')
  end

  def self.parse_json(json_pointer)
    if json_pointer.is_a?(FFI::Pointer)
      return 'null' if json_pointer.null?

      # begin
      ::LibStorj::Ext::JsonC.parse_json(json_pointer)
      # TODO: better error handling
      # rescue #=> e
      # end
    else
      throw 'json_pointer was a pointer (null or otherwise); json_pointer.class: #{json_pointer.class}'
    end
  end

  # default to highest strength; strength range: (128..256)
  def self.mnemonic_generate(strength = 256)
    # buffer = FFI::Buffer.new(32)
    # require 'pry'
    # binding.pry
    # buffer = FFI::MemoryPointer.new :char, 32
    # buffer_pointer = FFI::MemoryPointer.new :pointer
    # buffer_pointer.write_bytes buffer.address
    buffer = FFI::MemoryPointer.new :string
    buffer_pointer = FFI::MemoryPointer.new :pointer
    # ::LibStorj::Ext::

    ::LibStorj::Ext::Storj.mnemonic_generate(strength, pointer)
    # buffer.read_array
    # buffer.read_array_of_type(...)
    # buffer
    buffer.read_string
  end

  require 'ruby_libstorj/factory.rb'
  require 'ruby_libstorj/callback.rb'
end
