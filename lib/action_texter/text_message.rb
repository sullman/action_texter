module ActionTexter
  class TextMessage #:nodoc:
    attr_accessor :body, :from, :to

    def initialize(body='')
      @body = body

      @delivery_method = Configuration.instance.delivery_method
    end

    def encoded
      @body.strip
    end

    def destinations
      [@to]
    end

    def deliver
      delivery_method.deliver!(self)
    end

    def delivery_method(method = nil, settings = {})
      unless method
        @delivery_method
      else
        @delivery_method = Configuration.instance.lookup_delivery_method(method).new(settings)
      end
    end

    def delivery_method=(method)
      delivery_method(method)
    end

    def []=(name, value)
      send(:"#{name}=", value) if respond_to?(:"#{name}=")
    end
  end
end
