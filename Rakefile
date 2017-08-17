# NB: using begin/rescue so that you can use your
#     Rakefile in an environment where RSpec is
#     unavailable (e.g. production)
# (see https://relishapp.com/rspec/rspec-core/docs/command-line/rake-task)
begin
  # use local file rather than require through gem to run local code
  # i.e. `require 'ruby_libstorj/...'`
  require_relative './lib/ruby_libstorj/proxy_task'

  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec, %i[format] => []) do |t, args|
    rspec_opts = ''

    format, = args.values_at(*%i[format])
    rspec_opts << "--format #{format}" unless format.nil?

    t.rspec_opts = rspec_opts unless rspec_opts.empty?
  end

  LibStorj::ProxyTask.new(:spec, task_aliases: %i[test], args_deps_hash: {
      %i[format] => []
  })
rescue LoadError
  # supress `LoadError` exceptions...
end

# Register the task that's run when you `rake compile`
require 'rake/extensiontask'
Rake::ExtensionTask.new 'ruby_libstorj'

# TODO: everything that follows... but better
LibStorj::ProxyTask.new(:build, args_deps_hash: {
    %i[no-test] => []
}) do |t, args|
  Rake::Task[:spec].invoke if args.to_hash[:'no-test'].nil?

  directory 'tmp'

  sh 'gem build ./ruby_libstorj.gemspec'
  sh 'mv ./ruby_libstorj-*.gem ./tmp/'
end

LibStorj::ProxyTask.new(:install, args_deps_hash: {
    %i[no-test] => []
}) do |t, args|
  Rake::Task[:build].invoke(*args.to_a)

  sh 'gem install --local ./tmp/ruby_libstorj-*.gem \
                        --no-ri \
                        --no-rdoc'
end

# Build (and test) when you run `rake`
task default: %i[build]
