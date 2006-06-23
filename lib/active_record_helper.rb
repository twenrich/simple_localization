module ActionView #:nodoc
  class Base #:nodoc
    @@field_error_proc = Proc.new{ |html_tag, instance| "<span class=\"fieldWithErrors\">#{html_tag}</span>" }
    cattr_accessor :field_error_proc
  end
end