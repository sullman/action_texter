module ActionTexter
  module CheckDeliveryParams
    def check_delivery_params(message)
      if message.from.blank?
        raise ArgumentError.new('A From address is required to send a message.')
      end

      if message.to.blank?
        raise ArgumentError.new('A To address is required to send a message.')
      end

      body = message.encoded if message.respond_to?(:encoded)
      unless body
        raise ArgumentError.new('A body is required to send a message.')
      end

      [message.from, message.to, body]
    end
  end
end
