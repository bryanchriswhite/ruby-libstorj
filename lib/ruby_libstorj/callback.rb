module LibStorj
  module Callbacks
    GET_INFO_CALLBACK = LibStorj::Factory.callback(
        :get_info,
        %i[error_code response handle]
    ) do |req, error_code, response_pointer, callback|
      response = LibStorj.parse_json(response_pointer)
      error = if !error_code.nil?
                ::LibStorj::Ext::Curl.easy_stderr(error_code)
              elsif response.nil?
                'Failed to get info'
              end

      callback.call error, response
    end

    GET_BUCKETS_CALLBACK = LibStorj::Factory.callback(
        :get_buckets,
        %i[error_code buckets handle]
    ) do |req, error_code, buckets, handle|
      # do stuff ...
    end
  end

  CALLBACKS = {
      get_info: Callbacks::GET_INFO_CALLBACK,
      get_buckets: Callbacks::GET_BUCKETS_CALLBACK
  }.freeze
end