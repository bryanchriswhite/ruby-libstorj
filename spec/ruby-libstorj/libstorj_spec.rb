RSpec.describe LibStorj do
  describe '.util_timestamp' do
    let(:actual) {LibStorj.util_timestamp}
    let(:expected) {Time.new.to_f}

    it 'returns the current unix timestamp' do
      # / 1000 to convert from int of milliseconds to a float of seconds
      expect(actual / 1000).to eq(expected.floor)
    end
  end

  describe '.util_datetime' do
    let(:util_datetime) do
      LibStorj.util_datetime
    end

    let(:current_timestamp) do
      DateTime.now.to_time.to_i
    end

    def to_timestamp(datetime)
      datetime.to_time.to_i
    end

    it 'returns a `DateTime` object with the correct current time' do
      expect(util_datetime).to be_an_instance_of(DateTime)
      expect(to_timestamp(util_datetime)).to eq(current_timestamp)
    end
  end

  describe '.mnemonic_check' do
    let(:invalid_mnemonic) {'nope'}
    let(:valid_mnemonic) do
      'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about'
    end

    context 'with a valid mnenonic' do
      let(:mnemonic_check) do
        described_class.mnemonic_check valid_mnemonic
      end

      it 'returns true' do
        expect(mnemonic_check).to be(true)
      end
    end

    context 'with an invalid mnenonic' do
      let(:mnemonic_check) do
        described_class.mnemonic_check invalid_mnemonic
      end

      it 'returns false' do
        expect(mnemonic_check).to be(false)
      end
    end
  end
end
