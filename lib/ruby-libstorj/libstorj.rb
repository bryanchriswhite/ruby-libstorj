require 'rubygems'
require 'ffi'
require 'date'

module LibStorj
  # NB: not currently used but useful for debugging
  require 'ruby-libstorj/struct'
  require 'ruby-libstorj/ext/types'
  require 'ruby-libstorj/ext/ext'

  require 'ruby-libstorj/env'
  require 'ruby-libstorj/mixins/storj'

  extend ::LibStorj::Ext::Storj::Mixins

  def self.util_datetime
    # '%Q' - Number of milliseconds since 1970-01-01 00:00:00 UTC.
    DateTime.strptime(LibStorj.util_timestamp.to_s, '%Q')
  end
end
