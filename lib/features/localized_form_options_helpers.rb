module ArkanisDevelopment::SimpleLocalization #:nodoc
  module FormOptionsHelper #:nodoc
    
    Language[:countries].each do |original_name, localized_name|
      index = COUNTRIES.index original_name
      COUNTRIES[index] = localized_name
    end
    
  end
end

ActionView::Base.send :include, ArkanisDevelopment::SimpleLocalization::FormOptionsHelper