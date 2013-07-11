module ActionTexter
  module TextHelper
    # Access the texter instance.
    def texter
      @_controller
    end

    # Access the message instance.
    def message
      @_message
    end
  end
end
