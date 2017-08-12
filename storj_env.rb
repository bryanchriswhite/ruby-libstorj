require 'rubygems'
require 'ffi'
require_relative './libstorj'
require_relative 'ffi_shared'

class StorjEnv
  # include LibStorj
  # include FFI::Library
  include FFIShared

  def initialize(*options)
    puts options.inspect
    @storj_env_ptr = LibStorj.method(:init_env).call(*options)
  end

  def get_info(&block)
    puts @storj_env_ptr
    # puts LibStorj::Handle
    # puts LibStorj::GetInfoCallback
    handle = FFI::Function.new(:pointer, [:pointer]) do |pointer|
      puts 'hello from handle block1!!!'
    end

    get_info_callback = FFI::Function.new(:void, [LibStorj::Handle, :int]) do |handle, int|
      puts 'hello from get_info_callback block1!!!'
    end

    _get_info @storj_env_ptr, handle, get_info_callback
  end
end