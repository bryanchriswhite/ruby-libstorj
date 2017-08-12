$:.unshift File.join(File.dirname(__FILE__), "..", "lib"), File.join(File.dirname(__FILE__), "..", "build", RUBY_VERSION) unless RUBY_PLATFORM =~ /java/
require 'rubygems'
require 'ffi'
require 'date'
require_relative './ffi_shared'

module LibStorj
  include FFIShared

  attach_function('util_timestamp', 'storj_util_timestamp', [], :uint64)
  attach_function('mnemonic_check', 'storj_mnemonic_check', [:string], :bool)

  attach_function('_init_env', 'init_storj_ruby', [
      StorjBridgeOptions_t.ptr,
      StorjEncryptOptions_t.ptr,
      StorjHttpOptions_t.ptr,
      StorjLogOptions_t.ptr
  ], StorjEnv_t.ptr)
  private_class_method :_init_env

  # LibStorj::Handle = Proc.new {|p1, p2| POINTER.from_string('hello from Handle'.tap {|msg| puts msg})}
  # LibStorj::GetInfoCallback = Proc.new {|p1, p2| puts 'hello from GetInfoCallback' && nil}
  # LibStorj::Handle = FFI::Function.new(:pointer, [:pointer, :pointer]) do |result_ptr, error_ptr|
  #   # POINTER.from_string('hello from Handle'.tap {|msg| puts msg})
  #   puts 'hello from Handle'
  #   FFI::MemoryPointer.new :void
  # end
  # LibStorj::GetInfoCallback = FFI::Function.new(:void, [:pointer, :int]) do |uv_work_req_ptr, status|
  #   puts 'hello from GetInfoCallback'
  #   nil
  # end

  LibStorj::Handle = callback :handle, [:pointer, :pointer], :pointer
  # LibStorj::GetInfoCallback = callback :get_info_callback, [:pointer, :int], :void
  attach_function('_get_info', 'storj_bridge_get_info', [LibStorj::StorjEnv_t.ptr,
                                                         Handle,
                                                         :pointer], :int)
  private_class_method :_get_info

  def self.init_env(*options)
    puts options.inspect
    # options.each {|o| puts o.inspect}
    self.method(:_init_env).call(*options)
  end

  def self.util_datetime
    # '%Q' - Number of milliseconds since 1970-01-01 00:00:00 UTC.
    DateTime.strptime(util_timestamp.to_s, '%Q')
  end

end
