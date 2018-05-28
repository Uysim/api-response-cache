require 'rainbow'

require "api_response_cache/version"
require "api_response_cache/actions"
require "api_response_cache/api_cache_handler"
require "api_response_cache/response_cache"

ActionController::API.send(:include, ApiResponseCache::Actions)
