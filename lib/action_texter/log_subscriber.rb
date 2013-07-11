require 'active_support/core_ext/array/wrap'

module ActionTexter
  class LogSubscriber < ActiveSupport::LogSubscriber
    def deliver(event)
      recipients = Array.wrap(event.payload[:to]).join(', ')
      info("\nSent SMS to #{recipients} (%1.fms)" % event.duration)
      debug(event.payload[:body])
    end

    def logger
      ActionTexter::Base.logger
    end
  end
end

ActionTexter::LogSubscriber.attach_to :action_texter