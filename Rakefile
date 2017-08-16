# NB: using begin/rescue so that you can use your
#     Rakefile in an environment where RSpec is
#     unavailable (e.g. production)
# (see https://relishapp.com/rspec/rspec-core/docs/command-line/rake-task)
begin
  require 'rspec/core/rake_task'

  #(see https://github.com/ruby/rake/blob/68ef9140c11d083d8bb7ee5da5b0543e3a7df73d/lib/rake/dsl_definition.rb#L28)
  #
  #:call-seq:
  #       ... v-- We're using this signature --v
  #       task task_name, arguments => dependencies
  RSpec::Core::RakeTask.new(:spec, %i[format] => []) do |task, args|
    rspec_opts = ''

    format, = args.values_at(*%i[format])
    rspec_opts << "--format #{format}" unless format.nil?

    task.rspec_opts = rspec_opts unless rspec_opts.empty?
  end

  # add :test alias
  task test: %i[spec]
rescue LoadError
  # supress `LoadError` exceptions...
end

# Register the task that's run when you `rake compile`
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
