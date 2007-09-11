module ArkanisDevelopment::SimpleLocalization #:nodoc:
  module ExtendedErrorMessages
    
    module MessageExtension
      
      attr_accessor :prefix_with_attribute
      
      def prefix_with_attribute?
        @prefix_with_attribute
      end
      
      def substitute!(base, attribute)
        self.replace Language.substitute_entry(self, :model => base.class.localized_model_name) if base.class.respond_to?(:localized_model_name)
        self_before_attribute_substitution = self.dup
        self.replace Language.substitute_entry(self, :attr => base.class.human_attribute_name(attribute))
        self.prefix_with_attribute = true if self == self_before_attribute_substitution
      end
      
    end
    
  end
end

class ActiveRecord::Errors
  
  alias_method :add_without_substitution, :add
  
  def add(attribute, msg = @@default_error_messages[:invalid])
    msg.send :extend, ArkanisDevelopment::SimpleLocalization::ExtendedErrorMessages::MessageExtension
    msg.substitute! @base, attribute
    add_without_substitution(attribute, msg)
  end
  
  def full_messages
    full_messages = []
    
    @errors.each_key do |attr|
      @errors[attr].each do |msg|
        next if msg.nil?
        
        if attr == 'base' or not msg.prefix_with_attribute?
          full_messages << msg
        else
          full_messages << @base.class.human_attribute_name(attr) + " " + msg
        end
      end
    end
    full_messages
  end
  
end
