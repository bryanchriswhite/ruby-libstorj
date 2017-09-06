require 'rake'
require_relative '../helpers/shared_rake_examples'
require_relative '../../lib/ruby-libstorj/arg_forwarding_task'

RSpec.describe LibStorj::ArgForwardingTask do
  let(:instantiate) do
    described_class.new task_name,
                        alias_names: alias_names,
                        args_deps_hash: {args => deps},
                        &task_block
  end

  describe 'example_task' do
    let(:task_name) {:example_task}

    context 'without block' do
      let(:task_block) {nil}

      context 'without aliases' do
        let(:alias_names) {[]}

        context 'with args' do
          let(:args) {%i[first_arg second_arg third_arg]}

          context 'without deps' do
            let(:deps) {[]}

            before :all do
              Rake.application = Rake::Application.new
            end

            include_examples 'raises `ArgumentError`'
          end

          context 'with deps' do
            let(:deps) {%i[first_dep second_dep third_dep]}

            before :all do
              Rake.application = Rake::Application.new
            end


            include_examples 'raises `ArgumentError`'
          end
        end

        context 'without args' do
          let(:args) {[]}
          let(:expected_args) {{}}

          context 'without deps' do
            let(:deps) {[]}

            before :all do
              Rake.application = Rake::Application.new
            end

            include_examples 'raises `ArgumentError`'
          end

          context 'with deps' do
            let(:deps) {%i[first_dep second_dep third_dep]}

            before :all do
              Rake.application = Rake::Application.new
            end

            include_examples 'raises `ArgumentError`'
          end
        end
      end

      context 'with aliases' do
        let(:alias_names) {%i[first_alias second_alias third_alias]}

        context 'without args' do
          let(:args) {[]}
          let(:expected_args) {{}}

          context 'without deps' do
            let(:deps) {[]}

            before :all do
              Rake.application = Rake::Application.new
            end

            include_examples 'defines the target task'
            include_examples 'gets invoked via any alias'
          end

          context 'with deps' do
            let(:deps) {%i[first_dep second_dep third_dep]}

            before :all do
              Rake.application = Rake::Application.new
            end

            before do
              deps.each do |dep_name|
                Rake::Task.define_task dep_name
              end
            end

            include_examples 'defines the target task'
            include_examples 'gets invoked via any alias'
            include_examples 'invokes all dependencies when invoked'
            include_examples 'invokes all dependencies when invoked via any alias'
          end
        end

        context 'with args' do
          let(:args) {%i[first_arg second_arg third_arg]}
          let(:expected_args) do
            ### #=> {:first_arg => :first_value, ...}
            Hash[args.zip(%i[first_value second_value third_value])]
          end

          context 'without deps' do
            let(:deps) {[]}

            before :all do
              Rake.application = Rake::Application.new
            end

            include_examples 'defines the target task'
            # include_examples 'gets invoked with args via any alias'
          end

          context 'with deps' do
            let(:deps) {%i[first_dep second_dep third_dep]}

            before :all do
              Rake.application = Rake::Application.new
            end

            before do
              deps.each do |dep_name|
                Rake::Task.define_task dep_name
              end
            end

            include_examples 'defines the target task'
            include_examples 'gets invoked with args via any alias'
            include_examples 'invokes all dependencies when invoked'
            include_examples 'invokes all dependencies when invoked via any alias'
          end
        end
      end
    end

    context 'with block' do
      let(:task_block) do
        Proc.new do
          #-- noop
        end
      end

      context 'without aliases' do
        let(:alias_names) {[]}

        context 'without args' do
          let(:args) {[]}
          let(:expected_args) {{}}

          context 'without deps' do
            let(:deps) {[]}

            before :all do
              Rake.application = Rake::Application.new
            end

            include_examples 'defines the target task'
            include_examples 'yields to the block'
          end

          context 'with deps' do
            let(:deps) {%i[first_dep second_dep third_dep]}

            before :all do
              Rake.application = Rake::Application.new
            end

            before do
              deps.each do |dep_name|
                Rake::Task.define_task dep_name
              end
            end

            include_examples 'defines the target task'
            include_examples 'yields to the block'
            include_examples 'invokes all dependencies when invoked'
          end
        end

        context 'with args' do
          let(:args) {%i[first_arg second_arg third_arg]}
          let(:expected_args) do
            ### #=> {:first_arg => :first_value, ...}
            Hash[args.zip(%i[first_value second_value third_value])]
          end

          context 'without deps' do
            let(:deps) {[]}

            before :all do
              Rake.application = Rake::Application.new
            end

            include_examples 'defines the target task'
            include_examples 'yields to the block'
          end

          context 'with deps' do
            let(:deps) {%i[first_dep second_dep third_dep]}

            before :all do
              Rake.application = Rake::Application.new
            end

            before do
              deps.each do |dep_name|
                Rake::Task.define_task dep_name
              end
            end

            include_examples 'defines the target task'
            include_examples 'yields to the block'
            include_examples 'invokes all dependencies when invoked'
          end
        end
      end

      context 'with aliases' do
        let(:alias_names) {%i[first_alias second_alias third_alias]}

        context 'without args' do
          let(:args) {[]}
          let(:expected_args) {{}}

          context 'without deps' do
            let(:deps) {[]}

            before :all do
              Rake.application = Rake::Application.new
            end

            include_examples 'defines the target task'
            include_examples 'gets invoked via any alias'
          end

          context 'with deps' do
            let(:deps) {%i[first_dep second_dep third_dep]}

            before :all do
              Rake.application = Rake::Application.new
            end

            before do
              deps.each do |dep_name|
                Rake::Task.define_task dep_name
              end
            end

            include_examples 'defines the target task'
            include_examples 'gets invoked via any alias'
            include_examples 'invokes all dependencies when invoked'
            include_examples 'invokes all dependencies when invoked via any alias'
          end
        end

        context 'with args' do
          let(:args) {%i[first_arg second_arg third_arg]}
          let(:expected_args) do
            ### #=> {:first_arg => :first_value, ...}
            Hash[args.zip(%i[first_value second_value third_value])]
          end

          context 'without deps' do
            let(:deps) {[]}

            before :all do
              Rake.application = Rake::Application.new
            end

            include_examples 'defines the target task'
            include_examples 'gets invoked with args via any alias'
          end

          context 'with deps' do
            let(:deps) {%i[first_dep second_dep third_dep]}

            before :all do
              Rake.application = Rake::Application.new
            end

            before do
              deps.each do |dep_name|
                Rake::Task.define_task dep_name
              end
            end

            include_examples 'defines the target task'
            include_examples 'gets invoked with args via any alias'
            include_examples 'invokes all dependencies when invoked'
            include_examples 'invokes all dependencies when invoked via any alias'
          end
        end
      end
    end
  end
end
