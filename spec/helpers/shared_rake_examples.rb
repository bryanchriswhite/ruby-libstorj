def lookup_task(task_name)
  begin
    ::Rake::Task[task_name]
  rescue RuntimeError
    raise "exception raised when looking up rake task: #{task_name}"
  end
end


shared_examples 'defines the target task' do
  it 'defines the target task' do
    task = instantiate
    begin
      registered_task = ::Rake::Task[task_name]
      expect(registered_task).to be_equal(task.target_task)
    rescue RuntimeError => err
      fail("exception raised trying to lookup task: #{task_name}")
    end
  end
end

shared_context 'invokes all dependencies when invoked' do
  it 'invokes all depencencies when invoked' do
    task = instantiate
    deps.each do |dep_name|
      begin
        dep_task = ::Rake::Task[dep_name]
      rescue RuntimeError
        raise "exception raised when looking up rake task: #{dep_name}"
      end

      task.invoke(*expected_args.values)
      expect(dep_task.already_invoked).to be(true)

      #-- reset
      task.reenable
    end
  end
end

shared_context 'invokes all dependencies when invoked via any alias' do
  it 'invokes all depencencies when invoked via any alias' do
    task = instantiate
    alias_names.map(&method(:lookup_task)).each do |alias_task|
      alias_task.invoke(*expected_args.values)

      deps.map(&method(:lookup_task)).each do |dep_task|
        expect(dep_task.already_invoked).to be(true)

        #-- reset
        dep_task.reenable
      end

      #-- reset
      alias_task.reenable
    end
  end
end

shared_examples 'gets invoked with args via any alias' do
  it 'gets invoked with args via any alias' do
    yield_counter = 0
    task = described_class.new task_name,
                               alias_names: alias_names,
                               args_deps_hash: {args => deps} do
    |actual_task, actual_args, actual_deps|
      yield_counter += 1
      expect(task.target_task).to be(actual_task)
      expect(expected_args).to eq(actual_args.to_hash)
      expect(deps).to eq(actual_deps)
    end


    alias_names.map(&method(:lookup_task)).each do |alias_task|
      alias_task.invoke(*expected_args.values)

      #-- reset
      task.reenable
      alias_task.reenable
    end

    expect(yield_counter > 0).to be(true)
    expect(yield_counter).to be(alias_names.count)
  end
end

shared_examples 'gets invoked via any alias' do
  it 'gets invoked via any alias' do
    task = instantiate
    alias_names.each do |alias_name|
      begin
        alias_task = ::Rake::Task[alias_name]
      rescue RuntimeError
        raise "exception raised when looking up rake task: #{alias_name}"
      end

      alias_task.invoke(*expected_args.values)
      expect(task.already_invoked).to be(true)

      #-- reset
      task.reenable
      alias_task.reenable
    end
  end
end

shared_examples 'yields to the block' do
  it 'yields the rake task, args, and dependencies to the block' do
    task = described_class.new task_name,
                               alias_names: alias_names,
                               args_deps_hash: {args => deps} do
    |actual_task, actual_args, actual_deps|
      expect(task.target_task).to be(actual_task)
      expect(expected_args).to eq(actual_args.to_hash)
      expect(deps).to eq(actual_deps)
    end


    task.invoke(*expected_args.values)

    #-- reset
    task.reenable
  end
end

shared_context 'raises `ArgumentError`' do
  it 'raises an `ArgumentError`' do
    expect do
      instantiate
    end.to raise_error(ArgumentError)
  end
end
