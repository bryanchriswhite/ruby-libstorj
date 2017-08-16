# NB: so that you can use your Rakefile in an environment
#     where RSpec is unavailable (e.g. production)
begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)

  # alias
  task test: %i[spec]
rescue LoadError
  # supress `LoadError` exceptions
end

require 'rake/extensiontask'
Rake::ExtensionTask.new 'ruby_libstorj'

# TODO: everything that follows... but better
task build: %i[spec] do
  directory 'tmp'

  sh 'gem build ./ruby_libstorj.gemspec'
  sh 'mv ./ruby_libstorj-*.gem ./tmp/'
end

task install: %i[build] do
  sh 'gem install --local ./tmp/ruby_libstorj-*.gem \
                        --no-ri \
                        --no-rdoc'
end

# Build (and test) when you run `rake`
task default: %i[build]
