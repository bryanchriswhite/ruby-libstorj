require 'rake/extensiontask'

# NB: so that you can use your Rakefile in an environment
#     where RSpec is unavailable (e.g. production)
begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)

  # alias
  task :test => :spec
rescue LoadError
  # supress `LoadError` exceptions
end

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


# task test: TESTS do
#   storj = LibStorj::Env.new(*default_options)
#
#   storj.get_info do |error, response|
#     # TODO: figure out why error is "No error"
#     puts "error: #{error}"
#     puts "response: #{response}"
#   end
#
#   storj.get_buckets do |error, response|
#     puts "error: #{error}"
#     puts "response: #{response}"
#   end
# end
