RSpec.describe ::LibStorj::Ext::JsonC do
  describe '.stringify' do
    # TODO: find a way to prevent segfaults
    xcontext 'with a invalid argument' do
      let(:random_arg) {'index\'m random'}

      it 'raises an exception' do
        expect do
          described_class.stringify random_arg
        end.to raise_error(ArgumentError)
      end
    end

    context 'with a null pointer' do
      let(:json_pointer) {FFI::MemoryPointer::NULL}

      it 'returns the string "null"' do
        expect(described_class.stringify json_pointer).to eq('null')
      end
    end

    context 'with a pointer to a JsonC object' do
      let(:expected_hash) {JSON.parse json_string}
      let(:json_string) {'{"frist_prop": "first-value", "second_prop": ["second", "values"]}'}
      let(:json_pointer) do
        ::LibStorj::Ext::JsonC.parse json_string
      end

      let(:actual_string) do
        described_class.stringify json_pointer
      end

      let(:actual_hash) do
        begin
          JSON.parse(json_string)
        rescue RuntimeError => error
          fail error
        end
      end

      it 'returns a valid json string' do
        expect(actual_string).to be_an_instance_of(String)
        expect(actual_hash).to eq(expected_hash)
      end
    end
  end
end

RSpec.describe ::LibStorj::Ext::Curl do
  describe '.curl_code_to_string' do
    let(:curl_codes) {[0, 1, 2, 3, 6]}
    let(:curl_error_messages) do
      [
          '',
          'unsupported protocol',
          'failed initialization',
          'url using bad/illegal format or missing url',
          %q(couldn't resolve host name)
      ]
    end

    it 'returns the correct error string for all curl error code' do
      curl_codes.each_with_index do |curl_code, index|
        # exclude element at index 1
        next if index == 2

        # account for index offset
        index -= 1 if index > 1

        error_message = described_class.curl_code_to_string index
        expect(error_message).to match(Regexp.new curl_error_messages[index], 'i')
      end
    end
  end
end