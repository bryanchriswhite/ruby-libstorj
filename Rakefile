require 'rake/extensiontask'

Rake::ExtensionTask.new 'ruby_libstorj'

# TODO: everything that follows... but better
task :build do
  directory 'tmp'

  sh 'gem build ./ruby_libstorj.gemspec'
  sh 'mv ./ruby_libstorj-*.gem ./tmp/'
end

task :install => :build do
  sh 'gem install --local ./tmp/ruby_libstorj-*.gem \
                        --no-ri \
                        --no-rdoc'
end

# Build when you run `rake`
task :default => :build
