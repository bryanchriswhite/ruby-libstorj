# NB: all this ProxyTask business is to allow aliasing of rake tasks
#     while also forwarding arguments. We're using it here to allow
#     the tasks, "spec", and "test" work identically

# This constant stores the literal hash that is passed as the second argument
# to `Rake::Task.define_task`. To allow for additional arguments to be passed
# to this task
#
# (e.g. If we wanted to automate documentation output to a standard location
# we could add a second, 'out', arg that adds an `--out <file>` option to rspec.
#
# You would then invoke the task with that new argument like so: `rake test[doc, out]`
RSPEC_ARGS_DEPS_HASH = {%i[
    format
] => []}.freeze

class ProxyTask
  def initialize(proxied_task, new_task_names)
    new_task_names.flatten.each do |task_name|
      #(see https://github.com/ruby/rake/blob/68ef9140c11d083d8bb7ee5da5b0543e3a7df73d/lib/rake/dsl_definition.rb#L28)
      #
      #:call-seq:
      #       ... v-- We're using this signature --v
      #       task task_name, arguments => dependencies
      Rake::Task.define_task task_name, RSPEC_ARGS_DEPS_HASH do |t, args|
        Rake::Task[proxied_task].invoke(*args.to_a)
      end
    end
  end
end

# NB: using begin/rescue so that you can use your
#     Rakefile in an environment where RSpec is
#     unavailable (e.g. production)
# (see https://relishapp.com/rspec/rspec-core/docs/command-line/rake-task)
begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec, RSPEC_ARGS_DEPS_HASH) do |task, args|
    rspec_opts = ''

    format, = args.values_at(*%i[format])
    rspec_opts << "--format #{format}" unless format.nil?

    task.rspec_opts = rspec_opts unless rspec_opts.empty?
  end

  ProxyTask.new(:spec, %i[test])
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
