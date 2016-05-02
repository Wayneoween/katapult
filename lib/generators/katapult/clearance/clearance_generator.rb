# Generate authentication with Clearance

require 'katapult/generator'

module Katapult
  module Generators
    class ClearanceGenerator < Katapult::Generator

      desc 'Generate authentication with Clearance'

      check_class_collision
      source_root File.expand_path('../templates', __FILE__)


      def install_clearance
        insert_into_file 'Gemfile', "gem 'clearance'\n", before: "gem 'katapult'"
        run 'bundle install'
        invoke 'clearance:install'
      end

    end
  end
end
