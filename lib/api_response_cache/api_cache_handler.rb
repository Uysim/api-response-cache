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
        processor     = Rainbow("#{@controller.class.name}##{@controller.action_name}").blue
        responder     = Rainbow('API Response Cache').green
        Rails.logger.info "=== #{processor} response by #{responder} ==="
      end

      def init(controller)
        @controller         = controller
        @request            = controller.request
        @cache_path       ||= "api-response-cache/#{@options[:cache_path] || @request.fullpath}"

        @response_cache     = ResponseCache.new(@cache_path, @expires_in)
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
