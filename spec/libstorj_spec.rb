RSpec.describe LibStorj, '.util_datetime' do
  it 'should return the current unix timestamp' do
    date_time = LibStorj.util_datetime
    date_time.should be_an_instance_of(DateTime)
    # timestamp = LibStorj.util_timestamp
    # LibStorj.mnemonic_check
  end
end