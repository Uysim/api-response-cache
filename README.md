# API Response Cache
Improve your server response time by caching your response data to client side.

## Installation
Add to Gemfile
```
gem 'api-response-cache'
```
Then run
```
bundle install
```

## Configuration
If you want to change config create file at ```config/initializers/api_response_cache.rb```
```
ApiResponseCache.configure do |config|
  config.refresh_by_request_params = false  # true to saperate cache by request params
end
```

## TO DO
- [ ] Clear cache
- [ ] Expire cache
