require "action_texter"
require "rails"
require "abstract_controller/railties/routes_helpers"

module ActionTexter
  class Railtie < Rails::Railtie
    config.action_texter = ActiveSupport::OrderedOptions.new

    initializer "action_texter.logger" do
      ActiveSupport.on_load(:action_texter) { self.logger ||= Rails.logger }
    end

    initializer "action_texter.set_configs" do |app|
      paths   = app.config.paths
      options = app.config.action_texter

      options.assets_dir      ||= paths["public"].first
      options.javascripts_dir ||= paths["public/javascripts"].first
      options.stylesheets_dir ||= paths["public/stylesheets"].first

      # make sure readers methods get compiled
      options.asset_path          ||= app.config.asset_path
      options.asset_host          ||= app.config.asset_host
      options.relative_url_root   ||= app.config.relative_url_root

      ActiveSupport.on_load(:action_texter) do
        include AbstractController::UrlFor
        extend ::AbstractController::Railties::RoutesHelpers.with(app.routes)
        include app.routes.mounted_helpers

        options.each { |k,v| send("#{k}=", v) }
      end
    end

    initializer "action_texter.compile_config_methods" do
      ActiveSupport.on_load(:action_texter) do
        config.compile_methods! if config.respond_to?(:compile_methods!)
      end
    end
  end
end
