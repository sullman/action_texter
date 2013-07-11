
actionpack_path = File.expand_path('../../../actionpack/lib', __FILE__)
$:.unshift(actionpack_path) if File.directory?(actionpack_path) && !$:.include?(actionpack_path)

require 'abstract_controller'
require 'action_view'
require 'action_texter/version'

require 'active_support/core_ext/class'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/array/uniq_by'
require 'active_support/core_ext/module/attr_internal'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/string/inflections'
require 'active_support/lazy_load_hooks'

module ActionTexter
  extend ::ActiveSupport::Autoload

  autoload :Collector
  autoload :Base
  autoload :CheckDeliveryParams
  autoload :Configuration
  autoload :TextMessage
  autoload :FileDelivery
  autoload :TwilioDelivery
  autoload :DeliveryMethods
  autoload :TextHelper
end

require 'action_texter/railtie' if defined?(Rails)
