require 'twilio-ruby'

module ActionTexter
  class TwilioDelivery
    include CheckDeliveryParams

    def initialize(values)
      self.settings = { }.merge!(values)
    end

    attr_accessor :settings

    def deliver!(message)
      check_delivery_params(message)

      Rails.logger.info "Trying to deliver message via Twilio"
      Rails.logger.info "Settings are: #{settings}"

      client = Twilio::REST::Client.new(settings[:account_sid], settings[:token])
      account = client.account

      message.destinations.uniq.each do |to|
        account.sms.messages.create :from => message.from, :to => to, :body => message.encoded
      end
    end

  end
end
