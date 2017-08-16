require_relative './helpers/storj_options'

RSpec.describe LibStorj::Env do
  context 'creating' do
    it 'doesn\'t segfault' do
      begin
        storj_env = described_class.new(*default_options)
        storj_env.should be_an_instance_of(described_class)
      rescue => error
        fail(error)
      end
    end
  end
end