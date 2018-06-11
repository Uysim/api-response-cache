module ApiResponseCache
  class Config
    attr_accessor :refresh_by_request_params, :cache_by_headers

    def initialize
      @refresh_by_request_params = false
    end

    def refresh_by_request_params?
      @refresh_by_request_params
    end

  end
end
