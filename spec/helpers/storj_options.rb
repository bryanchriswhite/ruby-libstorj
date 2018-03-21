module LibStorjTest
  require 'ruby-libstorj'

  def get_test_bucket_id(&block)
    instance.get_buckets do |error, buckets|
      throw(:no_bucket) if buckets.nil?

      test_bucket = buckets.find {|bucket| bucket.name == test_bucket_name}
      throw(:no_bucket) unless test_bucket
      block.call test_bucket.id
    end
  end

  def get_test_file_id(&block)
    get_test_bucket_id do |test_bucket_id|
      instance.list_files test_bucket_id do |error, files|
        throw(:no_file) if files.nil?

        test_file = files.find {|file| file.name == test_file_name}
        throw(:no_file) unless test_file
        block.call test_file.id, test_bucket_id
      end
    end
  end


  def clean_buckets(&block)
    catch(:no_bucket) do
      return get_test_bucket_id do |id|
        instance.delete_bucket(id, &block)
      end
    end

    yield if block_given?
  end

  def clean_files(&block)
    catch(:no_bucket) do
      return get_test_bucket_id do |test_bucket_id|
        catch(:no_file) do
          get_test_file_id do |test_file_id|
            instance.delete_file(test_bucket_id, test_file_id, &block)
          end
        end
      end
    end

    yield if block_given?
  end
end
