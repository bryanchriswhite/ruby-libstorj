module LibStorj
  class Callback
    SIGNATURE_MAP = {
        uv_work: {
            return: :void,
            args: [::LibStorj::Ext::UV::Work.ptr, :int]
        }
    }

    SIGNATURE_MAP.default = SIGNATURE_MAP[:uv_work]
    SIGNATURE_MAP.freeze
    attr_reader :pointer

    def initialize(cast_map: nil,
                   member_names:,
                   work_data_struct:,
                   signature_name: :default, &block)
      throw 'A block is required but was not passed' unless block
      throw 'Keyword arg `member_names` array is required but was not passed' unless member_names.is_a? Array

      signature = SIGNATURE_MAP[signature_name]
      ffi_return, ffi_args = signature.values_at(*%i[return args])
      wrapped_block = Proc.new do |work_req_ptr, status|

        member_names

        req = work_data_struct.new work_req_ptr[:data]

        member_values = req.values_at(member_names.flatten.keep_if {|member|
          req.members.include? member
        })

        unless cast_map.nil? || cast_map.empty?
          member_values.map! do |original_value|
            member_name = member_names[member_values.index {|m| m == original_value}]
            next original_value unless member_names.include? member_name

            cast = cast_map[member_name]
            case cast.class.name
              # when Function
              #   cast.call original_value
              when 'Proc'
                cast.call original_value
              when 'Method'
                cast.call original_value
              else
                cast.new original_value
            end
          end
        end

        yield req, *member_values
      end

      @pointer = FFI::Function.new(ffi_return, ffi_args, wrapped_block)
    end
  end
end
