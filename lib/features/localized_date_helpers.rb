module ArkanisDevelopment::SimpleLocalization #:nodoc
  module DateHelper #:nodoc
    
    def date_select(object_name, method, options = {})
      options = Language[:helpers, :date_select].symbolize_keys.update(options)
      super object_name, method, options
    end
    
    def distance_of_time_in_words(from_time, to_time = 0, include_seconds = false)
      # TODO: implement it!
    end
    
  end
end

ActionView::Base.send :include, ArkanisDevelopment::SimpleLocalization::DateHelper