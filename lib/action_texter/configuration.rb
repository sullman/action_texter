require 'singleton'

module ActionTexter
  class Configuration
    include Singleton

    def initialize
      @delivery_method  = nil
      super
    end

    def delivery_method(method = nil, settings = {})
      return @delivery_method if @delivery_method && method.nil?
      @delivery_method = lookup_delivery_method(method).new(settings)
    end

    def lookup_delivery_method(method)
      case method.is_a?(String) ? method.to_sym : method
      when nil
        ActionTexter::FileDelivery
      when :twilio
        ActionTexter::TwilioDelivery
      when :file
        ActionTexter::FileDelivery
      else
        method
      end
    end
  end
end
