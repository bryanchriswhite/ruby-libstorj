require 'rubygems'
require 'ffi'
require 'libuv'

module Sample
  extend FFI::Library
  ffi_lib "#{__dir__}/sample.so", 'uv', 'c'

  # Sample::Callback = callback([:int], :int)

  # attach_function :greet, [Callback, :pointer], :int
  attach_function :queue_work, [:pointer, :pointer], :void
  attach_function :uv_run_default, [], :void
  attach_function :queue_work_without_gvl, [:pointer, :pointer], :void
  attach_function :uv_run_default_without_gvl, [], :void

  attach_function :callback, [:pointer], :void
  attach_function :after_callback, [:pointer, :int], :void
  Sample::Callback = FFI::Function.new(:void, [:pointer]) do |req|
    puts 'hello from Sample::Callback'
    callback req
  end
  Sample::AfterCallback = FFI::Function.new(:void, [:pointer, :int]) do |req, status|
    puts 'hello from Sample::AfterCallback'
    after_callback req, status
  end
end

# puts 'ruby: queue_work...'
# Sample.queue_work Sample::Callback, Sample::AfterCallback
# Sample.queue_work_without_gvl Sample::Callback, Sample::AfterCallback
# puts 'ruby: back from queue_work!'

# puts 'ruby: Sample.uv_run_default...'
# Sample.uv_run_default
# Sample.uv_run_default_without_gvl
# puts "reactor.running?: #{reactor.running?}"
# reactor.run
# puts "reactor.running?: #{reactor.running?}"
# puts 'ruby: back from Sample.uv_run_default!!'
# reactor.run
reactor do |reactor|
  puts 'starting work...'
  reactor.work {
    puts 'working...'
    # sleep 2
    puts "ruby: default_loop: 0x#{Libuv::Ext.default_loop.address.to_s(16)}"
    Sample.queue_work Sample::Callback, Sample::AfterCallback
    # Sample.queue_work_without_gvl Sample::Callback, Sample::AfterCallback
  # }.then {
  #   puts 'then 1'
  #   # sleep 2
  #   # puts 'slept...'
  # }.then {
  #   puts 'then 2'
  }
  puts 'done starting'
end

# handle = FFI::Function.new(:int, [:int]) do |int|
#   puts 'hello from handle block!!!'
#   puts "int: #{int}"
#   puts "returning: #{int * 2}"
#   int * 2
# end
#
# cb = FFI::Function.new(:int, [Sample::Callback]) do |_handle|
#   puts 'hello from cb block!!!'
#   _handle.call(7)
# end
# Sample.greet(handle, cb)