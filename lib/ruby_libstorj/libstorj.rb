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
      #   binding.pry
      # end
    else
      throw 'json_pointer was a pointer (null or otherwise); json_pointer.class: #{json_pointer.class}'
    end
  end

  require 'ruby_libstorj/factory.rb'
  require 'ruby_libstorj/callback.rb'
end
