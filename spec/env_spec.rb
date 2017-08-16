require_relative './helpers/storj_options'

RSpec.describe LibStorj::Env, 'new' do
  context 'creating' do
    before do
      begin
        @storj_env = described_class.new(*default_options)
      rescue => error
        fail(error)
      end
    end

    it 'should not segfault' do
      # pass
    end

    it 'should return an instans of LibStorj::Env' do
      @storj_env.should be_an_instance_of(described_class)
    end
  end
end