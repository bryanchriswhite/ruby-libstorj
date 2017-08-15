$:.unshift File.join(File.dirname(__FILE__), "..", "lib"), File.join(File.dirname(__FILE__), "..", "build", RUBY_VERSION) unless RUBY_PLATFORM =~ /java/
require 'rubygems'
require 'ffi'
require 'date'

module LibStorj
  require 'ruby_libstorj/struct'
  require 'ruby_libstorj/ext/types'
  require 'ruby_libstorj/ext/ext'

  require 'ruby_libstorj/env'

  include ::LibStorj::Ext::Storj::Public
  # util_timestamp
  # mnemonic_check

  def self.util_datetime
    # '%Q' - Number of milliseconds since 1970-01-01 00:00:00 UTC.
    DateTime.strptime(::LibStorj::Ext::Storj.util_timestamp.to_s, '%Q')
  end

  def self.parse_json(json_pointer)
    if json_pointer.is_a?(FFI::Pointer)
      return 'null' if json_pointer.null?

      # begin
      ::LibStorj::Ext::JsonC.parse_json(json_pointer)
      # TODO: better error handling
      # rescue #=> e
      #   binding.pry
      # end
    else
      throw 'json_pointer was a pointer (null or otherwise); json_pointer.class: #{json_pointer.class}'
    end
  end
end
