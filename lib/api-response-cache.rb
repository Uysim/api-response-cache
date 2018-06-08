require 'rainbow'

require "api_response_cache/version"
require "api_response_cache/actions"
require "api_response_cache/api_cache_handler"
require "api_response_cache/response_cache"
require "api_response_cache/config"

ActionController::API.send(:include, ApiResponseCache::Actions)

module ApiResponseCache
  def self.configure
    yield configuration
  end

  def self.configuration
    @configuration ||= ApiResponseCache::Config.new
  end

  def self.clear
     Rails.cache.delete_matched('api-response-cache/*')
  end
end
