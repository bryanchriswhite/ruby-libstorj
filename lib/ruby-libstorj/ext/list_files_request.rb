module LibStorj
  module Ext
    module Storj
      class ListFilesRequest < FFI::Struct
        layout :http_options, HttpOptions.by_ref,
               :encrypt_options, EncryptOptions.by_ref,
               :options, BridgeOptions.by_ref,
               :bucket_id, :string,
               :method, :string,
               :path, :string,
               :auth, :bool,
               :body, :pointer, # struct json_object *body;
               :response, :pointer, # struct json_object *response;
               :files, :pointer,
               :total_files, :uint32,
               :error_code, :int,
               :status_code, :int,
               :handle, :pointer # void*

        def self.after_work_cb
          args = [::LibStorj::Ext::UV::Work.by_ref, :int]

          FFI::Function.new :void, args do |work_req_ptr|
            req = self.new work_req_ptr[:data]
            files, total_files, response = req.values_at %i[files total_files response]
            error = ::LibStorj::Ext::Curl.curl_code_to_string req[:error_code]
            c_handle = FFI::Function.new :void, %i[string pointer int], req[:handle]

            catch :no_response_error do
              begin
                response_string = ::LibStorj::Ext::JsonC.stringify(response)
                response_hash = JSON.parse(response_string)

                unless response_hash.is_a?(Hash) && !response_hash['error'].nil?
                  throw :no_response_error
                end

                error = response_error if response_error && error.empty?
              rescue JSON::ParserError => err
                # response didn't contain valid JSON;
                # therefore, it probably doesn't contain an error message
              end
            end

            c_handle.call error, files, total_files
          end
        end

        def self.ruby_handle(&block)
          FFI::Function.new :void, %i[string pointer int] do
          |error, files_pointer, file_count|
            files = ::LibStorj::Ext::Storj::File.pointer_to_array files_pointer,
                                                                  file_count

            error = nil if error.empty?

            yield error, files
          end
        end
      end
    end
  end
end