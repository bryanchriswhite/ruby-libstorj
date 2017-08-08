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

  LibStorj::Handle = Proc.new {|p1, p2| 'hello from Handle'.tap {|msg| puts msg}}
  LibStorj::GetInfoCallback = Proc.new {|p1, p2| 'hello from GetInfoCallback' && nil}

  callback :handle, [:pointer, :pointer], :pointer
  callback :get_info_callback, [:pointer, :int], :void
  attach_function('_get_info', 'storj_bridge_get_info', [LibStorj::StorjEnv_t.ptr,
                                                         :handle,
                                                         :get_info_callback], :int)
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
