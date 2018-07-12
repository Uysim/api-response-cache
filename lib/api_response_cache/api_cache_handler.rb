module ApiResponseCache
  module Actions
    class ApiCacheHandler
      def initialize(options)
        @options       = options
        @expires_in    = @options[:expires_in]
      end


      def around(controller)
        init(controller)
        if should_response_cache?
          log_info
          render_cached_response
        else
          yield
          @response_cache.write_cache(controller.response) if @request.get?
        end
      end

      protected

      def should_response_cache?
        @request.get? && @response_cache.present?
      end

      def log_info
        processor       = "#{@controller.class.name}##{@controller.action_name}".blue
        responder       = Rainbow('API Response Cache').green
        Rails.logger.info "=== #{processor} response by #{responder} ==="
      end

      def init(controller)
        @controller         = controller
        @request            = controller.request
        @response_cache     = ResponseCache.new(cache_path, @expires_in)
      end

      def cache_path
        @cache_path = "api-response-cache"

        if @options[:cache_path].present?
          @cache_path = "#{@cache_path}/#{@options[:cache_path]}"
        elsif ApiResponseCache.configuration.refresh_by_request_params?
          @cache_path = "#{@cache_path}/#{@request.fullpath}"
        else
          path_only   = @request.fullpath.split('?').first
          @cache_path = "#{@cache_path}/#{path_only}"
        end

        if ApiResponseCache.configuration.cache_by_headers.present?
          headers = ApiResponseCache.configuration.cache_by_headers.map do |header|
            @request.headers[header].to_s
          end
          headers_cache_path = headers.join('-')
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

