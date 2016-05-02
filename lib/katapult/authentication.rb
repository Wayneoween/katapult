require 'generators/katapult/clearance/clearance_generator'

module Katapult
  class Authentication < Element

    attr_accessor :system_email

    def ensure_user_model_attributes_present
      user_model = application_model.get_model('User')
      user_attrs = user_model.attrs.map(&:name)

      %i[email password].each do |attr|
        user_model.attr(attr) unless user_attrs.include?(attr.to_s)
      end
    end

    def render
      Generators::ClearanceGenerator.new(self).invoke_all
    end

    private

    def ensure_attribute(model, attr)
    end

  end
end
