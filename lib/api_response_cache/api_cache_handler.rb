module ApiResponseCache
  module Actions
    class ApiCacheHandler
      def initialize(options)
        @options       = options
        @expires_in    = @options[:expires_in]
      end


      def around(controller)
        init(controller)
        if @request.get? && @response_cache.present? &&
          log_info
          render_cached_response
        else
          yield
          @response_cache.write_cache(controller.response)
        end
      end

      protected

      def log_info
        processor     = @processor_name.blue
        responder     = Rainbow('API Response Cache').green
        Rails.logger.info "=== #{processor} response by #{responder} ==="
      end

      def init(controller)
        @controller         = controller
        @request            = controller.request
        @processor_name     = "#{@controller.class.name}##{@controller.action_name}"
        @response_cache     = ResponseCache.new(cache_path, @expires_in)
      end

      def cache_path
        return @cache_path if @cache_path.present?

        @cache_path = "api-response-cache/#{@processor_name || @options[:cache_path]}"

        if ApiResponseCache.configuration.refresh_by_request_params?
          @cache_path = "#{@cache_path}#{@request.fullpath}"
        end

        if ApiResponseCache.configuration.cache_by_headers.present?
          cache_by_headers = ApiResponseCache.configuration.cache_by_headers
          headers = @request.headers.select{ |key, value| cache_by_headers.include?(key) }
          headers_cache_path = headers.to_json
          @cache_path = "#{@cache_path}/#{headers_cache_path}"
        end

        @cache_path
      end

      def render_cached_response
        body    = @response_cache.body
        status  = @response_cache.status
        headers = @response_cache.headers

        headers.each do |key, value|
          @controller.response.headers[key] = value
        end

        @controller.render plain: body, status: status
      end
    end
  end
end
