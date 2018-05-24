module ApiResponseCache
  module Actions
    extend ActiveSupport::Concern
    module ClassMethods
      def cache_response_for(*actions)
        options = actions.extract_options!
        filter_options = options.extract!(:if, :unless).merge(only: actions)
        around_action  ApiCacheHandler.new(options), filter_options
      end
    end
  end
end
