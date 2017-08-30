RSpec.describe FFI::Struct do
  before :all do
    class SimpleStruct < FFI::Struct
      layout :first_string, :pointer,
             :second_string, :pointer,
             :third_string, :pointer
    end

    class ComplexStruct < FFI::Struct
      layout :simple_struct_1, SimpleStruct.by_ref,
             :simple_struct_2, SimpleStruct.by_ref,
             :another_string, :pointer,
             :null_member, :pointer
    end
  end

  let(:simple_values) {%w[first-value second-value third-value]}
  let(:simple_hash) do
    Hash[SimpleStruct.members.zip(simple_values)]
  end

  let(:another_string) {'another string'}
  let(:complex_hash) do
    {
        simple_struct_1: simple_hash,
        simple_struct_2: simple_hash,
        another_string: another_string,
        null_member: nil
    }
  end

  let(:simple_struct) do
    struct = SimpleStruct.new
    struct.members.each_with_index do |member_name, i|
      string = simple_values[i]
      struct[member_name] = FFI::MemoryPointer.from_string string
    end
    struct
  end

  let(:complex_struct) do
    complex_struct = ComplexStruct.new
    2.times do |i|
      complex_struct[:"simple_struct_#{i + 1}"] = simple_struct
    end
    complex_struct[:another_string] = FFI::MemoryPointer.from_string(another_string)
    complex_struct[:null_member] = FFI::MemoryPointer::NULL
    complex_struct
  end

  describe '.values_at' do
    it 'returns the values of the members whose names are passed, in the same order' do
      struct = simple_struct
      values = struct.values_at(struct.members).map(&:read_string)
      expect(values).to eq(simple_values)
    end
  end

  describe '.map_layout' do
    it 'returns a hash representing the nested struct layout' do
      expect(complex_struct.map_layout).to eq(complex_hash)
    end
  end
end