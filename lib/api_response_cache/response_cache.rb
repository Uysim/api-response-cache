module ApiResponseCache
  module Actions
    class ResponseCache
      def initialize(cache_path, expires_in)
        @cache_path = cache_path
        @expires_in = expires_in || 1.hour
      end

      def present?
        cached_response.present?
      end

      def body
        cached_response['body']
      end

      def status
        cached_response['status']
      end

      def headers
        cached_response['headers']
      end

      def cached_response
        @cached_response ||= Rails.cache.read(@cache_path)
      end

      def write_cache(response)
        cache_object = {
          body: response.body,
          status: response.status,
          headers: response.headers
        }.as_json
        Rails.cache.write(@cache_path, cache_object, expires_in: @expires_in)
      end

    end
  end
end
