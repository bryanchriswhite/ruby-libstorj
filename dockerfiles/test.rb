require 'ruby-libstorj'
require_relative './storj_options'

include LibStorjTest
storj = LibStorj::Env.new(*default_options)

storj.get_buckets do |error, buckets|
  puts "error: #{error}"
  puts "buckets: #{buckets}"
end
