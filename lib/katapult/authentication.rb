require 'generators/katapult/clearance/clearance_generator'

module Katapult
  class Authentication < Element

    attr_accessor :system_email

    def render
      Generators::ClearanceGenerator.new(self).invoke_all
    end

  end
end
