require 'action_texter/collector'
require 'active_support/core_ext/array/wrap'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/proc'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/hash/except'
require 'active_support/core_ext/module/anonymous'
require 'action_texter/log_subscriber'

module ActionTexter #:nodoc:
  class Base < AbstractController::Base
    include DeliveryMethods
    abstract!

    include AbstractController::Logger
    include AbstractController::Rendering
    include AbstractController::Layouts
    include AbstractController::Helpers
    include AbstractController::Translation
    include AbstractController::AssetPaths

    self.protected_instance_variables = %w(@_action_has_layout)

    helper  ActionTexter::TextHelper

    private_class_method :new #:nodoc:

    class_attribute :default_params
    self.default_params = {
      :charset      => "UTF-8",
      :content_type => "text/plain"
    }.freeze

    class << self
      # TODO(sullman): Observers? Interceptors?

      def texter_name
        @texter_name ||= anonymous? ? "anonymous" : name.underscore
      end
      attr_writer :texter_name
      alias :controller_path :texter_name

      def default(value = nil)
        self.default_params = default_params.merge(value).freeze if value
        default_params
      end

      def respond_to?(method, include_private = false) #:nodoc:
        super || action_methods.include?(method.to_s)
      end

    protected

      def method_missing(method, *args) #:nodoc:
        return super unless respond_to?(method)
        new(method, *args).message
      end
    end

    attr_internal :message

    # Instantiate a new texter object. If +method_name+ is not +nil+, the texter
    # will be initialized according to the named method. If not, the texter will
    # remain uninitialized (useful when you only need to invoke the "receive"
    # method, for instance).
    def initialize(method_name=nil, *args)
      super()
      @sms_was_called = false
      @_message = SimpleText.new
      process(method_name, *args) if method_name
    end

    def process(*args) #:nodoc:
      # Why is this necessary?
      lookup_context.view_paths = "#{Rails.root}/app/views"
      lookup_context.skip_default_locale!

      super
      @_message = SimpleText.new unless @sms_was_called
    end

    class SimpleText #:nodoc:
      attr_accessor :body, :from, :to

      def initialize(body='')
        @body = body
        @from = ''
        @to = ''
      end

      def method_missing(*args)
        nil
      end
    end

    def texter_name
      self.class.texter_name
    end

    # The main method that creates the message and renders the text templates. There are
    # two ways to call this method, with a block, or without a block.
    #
    # Both methods accept an options hash. This hash allows you to specify the most used
    # variables for a message, such as:
    #
    # * <tt>:to</tt> - Who the message is destined for, can be a string of addresses, or an array
    #   of addresses.
    # * <tt>:from</tt> - Who the message is from
    #
    # You can set default values for these options by using the <tt>default</tt>
    # class method:
    #
    #  class Notifier < ActionTexter::Base
    #    self.default :from => '+15551234567'
    #  end
    #
    # If you do not pass a block to the +sms+ method, it will find all templates in the
    # view paths using by default the texter name and the method name that it is being
    # called from. It will return a fully prepared ActionTexter::Message ready to call
    # <tt>:deliver</tt> on to send.
    #
    # For example:
    #
    #   class Notifier < ActionTexter::Base
    #     default :from => '+15551234567',
    #
    #     def welcome
    #       sms(:to => '+15557654321')
    #     end
    #   end
    #
    # Will look for all templates at "app/views/notifier" with name "welcome". However, those
    # can be customized:
    #
    #   sms(:template_path => 'notifications', :template_name => 'another')
    #
    # And now it will look for all templates at "app/views/notifications" with name "another".
    #
    # If you do pass a block, you can render specific templates of your choice:
    #
    #   sms(:to => '+15557654321') do |format|
    #     format.text
    #     format.html
    #   end
    #
    # You can even render text directly without using a template:
    #
    #   sms(:to => '+15557654321') do |format|
    #     format.text { render :text => "Hello Mikel!" }
    #   end
    #
    def sms(options={}, &block)
      @sms_was_called = true
      m = @_message = TextMessage.new

      content_type = options[:content_type]

      # Call all the procs (if any)
      default_values = self.class.default.merge(self.class.default) do |k,v|
        v.respond_to?(:call) ? v.bind(self).call : v
      end

      # Handle defaults
      options = options.reverse_merge(default_values)

      # Set configure delivery behavior
      wrap_delivery_behavior!(options.delete(:delivery_method))

      # Assign everything we expect to be assignable, except body.
      assignable = options.extract!(:from, :to)
      assignable.each { |k, v| m[k] = v }

      # Render the templates and blocks
      responses = collect_responses(options, &block)
      create_body_from_responses(m, responses)

      m
    end

  protected

    def collect_responses(options) #:nodoc:
      responses = []

      if block_given?
        collector = ActionTexter::Collector.new(lookup_context) { render(action_name) }
        yield(collector)
        responses  = collector.responses
      elsif options[:body]
        responses << {
          :body => options.delete(:body),
          :content_type => self.class.default[:content_type] || "text/plain"
        }
      else
        templates_path = options.delete(:template_path) || self.class.texter_name
        templates_name = options.delete(:template_name) || action_name

        each_template(templates_path, templates_name) do |template|
          self.formats = template.formats

          responses << {
            :body => render(:template => template),
            :content_type => template.mime_type.to_s
          }
        end
      end

      responses
    end

    def each_template(paths, name, &block) #:nodoc:
      templates = lookup_context.find_all(name, Array.wrap(paths))
      templates.uniq_by { |t| t.formats }.each(&block)
    end

    def create_body_from_responses(m, responses) #:nodoc:
      body = nil
      responses.each do |r|
        body ||= r[:body] if r[:content_type] == 'text/plain'
      end

      body ||= responses.first[:body]

      m.body = body
    end

    ActiveSupport.run_load_hooks(:action_texter, self)
  end
end
