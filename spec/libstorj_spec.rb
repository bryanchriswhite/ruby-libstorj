RSpec.describe LibStorj do
  describe '.util_timestamp' do
    it 'should return the current unix timestamp' do
      actual = LibStorj.util_timestamp
      expected = Time.new.to_f

      # / 1000 to convert from int of milliseconds to a float of seconds
      (actual / 1000).should eq(expected.floor)
      # timestamp = LibStorj.util_timestamp
      # LibStorj.mnemonic_check
    end
  end

  describe '.util_datetime' do
    it 'should return the current a `DateTime` object with the current time' do
      actual = LibStorj.util_datetime
      expected = DateTime.now.to_time.to_i

      # / 1000 to convert from int of milliseconds to a float of seconds
      actual.should be_an_instance_of(DateTime)
      (actual.to_time.to_i).should eq(expected)
      # timestamp = LibStorj.util_timestamp
      # LibStorj.mnemonic_check
    end
  end
end
