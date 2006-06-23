module ArkanisDevelopment #:nodoc
	module Localization #:nodoc
		module Helper #:nodoc
			def error_messages_for(object_name)
				object = instance_variable_get("@#{object_name}")
				if object and !object.errors.empty?
					render :partial => 'shared/errors', :locals => {:object => object}
				else
					''
				end
			end
		end
	end
end