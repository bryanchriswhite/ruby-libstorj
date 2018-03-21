# use local file rather than require through gem to run local code
# i.e. `require 'ruby-libstorj/...'`
require_relative './lib/ruby-libstorj/arg_forwarding_task'

TEMP_PATH = File.join(%W(#{__dir__} tmp))

# NB: using begin/rescue so that you can use your
#     Rakefile in an environment where RSpec is
#     unavailable (e.g. production)
# (see https://relishapp.com/rspec/rspec-core/docs/command-line/rake-task)
begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:rspec, [:format] => []) do |t, args|
    rspec_opts = ''

    format_name = args.values_at(*%i[format])
    format = %i[
       progress
       documentation
       html
       json
    ].reject {|f| (f =~ /^#{format_name}/).nil?}.first

    rspec_opts << "--format #{format}" unless (format.nil? || format.empty?)

    t.rspec_opts = rspec_opts unless rspec_opts.empty?
  end

  LibStorj::ArgForwardingTask.new :spec,
                                  alias_names: [:test],
                                  args_deps_hash: {
                                      %i[format open_coverage] => [:rspec]
                                  } do |t, args|
    ### NB: this task only prints the file url line after `simplecov`s output.
    #       and optionally open it in the default browser. It depends on :rspec,
    #       which ensures that the tests get run and that this runs after.
    coverage_url = "file:///#{__dir__}/coverage/index.html"
    open_coverage = (args.to_hash[:open_coverage] =~ /^y(es)?$/)
    if open_coverage
      puts "Opening: #{coverage_url}"
      require 'launchy'
      Launchy.open coverage_url
    else
      puts "Open in a browser: #{coverage_url}"
    end
  end
rescue LoadError
  # supress `LoadError` exceptions...
end

# Register the task that's run when you `rake compile`
require 'rake/extensiontask'
Rake::ExtensionTask.new 'ruby-libstorj'

# TODO: everything that follows... but better
LibStorj::ArgForwardingTask.new(:build, args_deps_hash: {
    %i[no-test] => [TEMP_PATH.to_sym]
}) do |t, args, deps|
  Rake::Task[:spec].invoke if args.to_hash[:'no-test'].nil?

  sh 'gem build ruby-libstorj.gemspec'
  sh "mv ruby-libstorj-*.gem #{TEMP_PATH}#{File::SEPARATOR}"
end

LibStorj::ArgForwardingTask.new(:install, args_deps_hash: {
    %i[no-test] => []
}) do |t, args|
  Rake::Task[:build].invoke(*args.to_a)

  sh 'gem install --local ./tmp/ruby-libstorj-*.gem \
                        --no-ri \
                        --no-rdoc'
end

directory TEMP_PATH

# Build (and test) when you run `rake`
task default: %i[build]
