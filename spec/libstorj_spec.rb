RSpec.describe LibStorj do
  describe '.util_timestamp' do
    it 'returns the current unix timestamp' do
      actual = LibStorj.util_timestamp
      expected = Time.new.to_f

      # / 1000 to convert from int of milliseconds to a float of seconds
      expect(actual / 1000).to eq(expected.floor)
    end
  end

  describe '.util_datetime' do
    it 'returns a `DateTime` object with the correct current time' do
      actual = LibStorj.util_datetime
      expected = DateTime.now.to_time.to_i

      expect(actual).to be_an_instance_of(DateTime)
      expect(actual.to_time.to_i).to eq(expected)
    end
  end

  describe '.mnemonic_check' do
    before do
      @valid_mnemonic = 'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about'
      @invalid_mnemonic = 'nope'
    end

    context 'with a valid mnenonic' do

      it 'returns true' do
        actual = described_class.mnemonic_check @valid_mnemonic
        expected = DateTime.now.to_time.to_i

        expect(actual).to be(true)
      end
    end

    context 'with an invalid mnenonic' do
      it 'returns false' do
        actual = described_class.mnemonic_check @invalid_mnemonic
        expected = DateTime.now.to_time.to_i

        expect(actual).to be(false)
      end
    end
  end

  describe '.mnemonic_generate' do
    context 'with valid strength' do
      it 'returns a random, valid mnemonic', debug: true do
        mnemonic = described_class.mnemonic_generate
        is_valid = LibStorj.mnemonic_check mnemonic

        expect(mnemonic).to be_an_instance_of(String)
        expect(mnemonic.length < 0).to be(true)
        expect(is_valid).to be(true)
      end
    end

    context 'with invalid strength' do
      it 'reaises an exception' do
        pending
      end
    end
  end
end
