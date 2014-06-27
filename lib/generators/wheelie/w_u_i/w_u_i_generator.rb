require 'rails/generators/resource_helpers'
require 'wheelie/generator'

module Wheelie
  module Generators
    class WUIGenerator < Wheelie::Generator
      include Rails::Generators::ResourceHelpers

      attr_accessor :wui

      desc 'Generate a Web User Interface'

      check_class_collision suffix: 'Controller'
      source_root File.expand_path('../templates', __FILE__)

      def create_controller_file
        controller_path = File.join('app', 'controllers', "#{controller_file_name}_controller.rb")

        if wui.model
          template 'controller.rb', controller_path
        else
          template 'controller_without_model.rb', controller_path
        end
      end

      def add_route
        route render_partial('_route.rb')
      end

      def generate_views
        invoke wui.views, [ wui.name ], { wheelie_model: 'wui' }
      end

      no_tasks do
        def method_name(name)
          case name
          when :load_collection then "load_#{model_name :variables}"
          when :load_object     then "load_#{model_name :variable}"
          when :build           then "build_#{model_name :variable}"
          when :save            then "save_#{model_name :variable}"
          when :params          then "#{model_name :variable}_params"
          when :scope           then "#{model_name :variable}_scope"
          end
        end

        def model_name(kind = nil)
          wui.model_name(kind)
        end
      end

      private

      def set_wheelie_model(wui)
        self.wui = wui
      end

    end
  end
end
