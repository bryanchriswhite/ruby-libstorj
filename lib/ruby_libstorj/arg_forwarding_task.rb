# TODO: re-document... implementation has changed
# NB: all this ProxyTask business is to allow aliasing of rake tasks
#     while also forwarding arguments. We're using it here to allow
#     the tasks, "spec", and "test" work identically
module LibStorj
  class ArgForwardingTask
    def initialize(target, task_aliases: [nil], args_deps_hash:, &block)
      task_aliases.flatten.each do |task_name|
        # if no aliases, register `target` with no dependencies
        if task_name.nil?
          #(see https://github.com/ruby/rake/blob/68ef9140c11d083d8bb7ee5da5b0543e3a7df73d/lib/rake/dsl_definition.rb#L28)
          #
          #:call-seq:
          #      ... v-- We're using this signature --v
          #      Rake::Task.define_task task_name, arguments => dependencies
          next block ?
                   Rake::Task.define_task(target, args_deps_hash, &block) :
                   Rake::Task.define_task(target, args_deps_hash)
        end

        Rake::Task.define_task task_name, args_deps_hash do |t, args|
          block ?
              Rake::Task[target].invoke(*args.to_a, &block) :
              Rake::Task[target].invoke(*args.to_a)
        end
      end
    end
  end
end
