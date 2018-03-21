require 'ruby-libstorj'

options_path = File.join %W(#{__dir__} options.yml)
storj = LibStorj::Env.new(path: options_path)

storj.get_buckets do |error, buckets|
  puts "error: #{error}"
  puts "buckets: #{buckets}"
end
