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
    # uv_work_cb
    # handle_proc = Proc.new {puts 'handle_proc called!!'}
    # cb_proc = Proc.new {puts 'cb_proc called!!'}
    handle_proc = LibStorj::Handle
    cb_proc = LibStorj::GetInfoCallback
    _get_info @storj_env_ptr, handle_proc, cb_proc
  end
end