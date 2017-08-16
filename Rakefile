require 'rake/extensiontask'

Rake::ExtensionTask.new 'ruby_libstorj'

# TODO: everything that follows... but better
task :build do
  directory 'tmp'

  sh 'gem build ./ruby_libstorj.gemspec'
  sh 'mv ./ruby_libstorj-*.gem ./tmp/'
end

task install: :build do
  sh 'gem install --local ./tmp/ruby_libstorj-*.gem \
                        --no-ri \
                        --no-rdoc'
end

# Build when you run `rake`
task default: :build


# wip testing
require_relative './test'
TESTS = %i[
  get_info
  get_buckets
]

task :get_info do

end

task test: TESTS do
  storj = LibStorj::Env.new(*default_options)

  storj.get_info do |error, response|
    # TODO: figure out why error is "No error"
    puts "error: #{error}"
    puts "response: #{response}"
  end

  storj.get_buckets do |error, response|
    puts "error: #{error}"
    puts "response: #{response}"
  end
end
