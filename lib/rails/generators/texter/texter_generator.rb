module Rails
  module Generators
    class TexterGenerator < NamedBase
      source_root File.expand_path("../templates", __FILE__)

      argument :actions, :type => :array, :default => [], :banner => "method method"
      check_class_collision

      def create_texter_file
        template "texter.rb", File.join('app/texters', class_path, "#{file_name}.rb")
      end

      hook_for :template_engine
    end
  end
end
