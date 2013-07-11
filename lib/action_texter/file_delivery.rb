module ActionTexter

  # FileDelivery class delivers messages into files based on the destination
  # address.  Each file is appended to if it already exists.
  #
  # Make sure the path you specify with :location is writable by the Ruby process.
  class FileDelivery
    include CheckDeliveryParams

    if RUBY_VERSION >= '1.9.1'
      require 'fileutils'
    else
      require 'ftools'
    end

    def initialize(values)
      self.settings = { :location => './texts' }.merge!(values)
    end

    attr_accessor :settings

    def deliver!(message)
      check_delivery_params(message)

      if ::File.respond_to?(:makedirs)
        ::File.makedirs settings[:location]
      else
        ::FileUtils.mkdir_p settings[:location]
      end

      message.destinations.uniq.each do |to|
        ::File.open(::File.join(settings[:location], File.basename(to.to_s)), 'a') { |f| f.write("#{message.encoded}\r\n\r\n") }
      end
    end

  end
end
