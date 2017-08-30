RSpec.describe ::LibStorj::Ext::Storj::JsonRequest do
  describe '.ruby_handle' do
    context 'with json parse error' do
      let(:invalid_json_string) {'{invalid_prop: "first-value", "second_prop": ["second", "values"]}'}

      it 'yields the json parse error and a nil response' do
        expect do |block|
          described_class.ruby_handle(&block).call '', invalid_json_string
        end.to yield_with_args(JSON::ParserError, nil)
      end
    end
  end
end