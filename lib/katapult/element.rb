# The base class for all katapult elements to inherit from.

# Every katapult element has a name which is a String. All options passed will
# be mapped to attributes. Afterwards, the optional block will be yielded with
# self.

module Katapult
  class Element

    UnknownOptionError = Class.new(StandardError)
    UnknownFormattingError = Class.new(StandardError)

    attr_accessor :name, :options
    attr_reader :application_model

    # Improve semantics in element classes
    class << self
      alias_method :options, :attr_accessor
    end


    def initialize(name, options = {})
      self.name = name.to_s
      self.options = options

      set_attributes(options)

      yield(self) if block_given?
    end

    def set_application_model(app_model)
      @application_model = app_model
    end

    def name(kind = nil)
      machine_name = @name.underscore
      human_name = machine_name.humanize.downcase

      case kind.to_s
      when ''          then @name
      when 'symbol'    then ":#{machine_name}"
      when 'symbols'   then ":#{machine_name.pluralize}"
      when 'variable'  then machine_name
      when 'variables' then machine_name.pluralize
      when 'ivar'      then "@#{machine_name}"
      when 'ivars'     then "@#{machine_name.pluralize}"
      when 'human'     then human_name
      when 'humans'    then human_name.pluralize
      when 'class'     then machine_name.classify
      when 'classes'   then machine_name.classify.pluralize
      else raise UnknownFormattingError, "Unknown name formatting: #{ kind.inspect }"
      end
    end

    private

    # Map options to attributes.
    # Example: set_attributes(foo: 123) sets the :foo attribute to 123 (via
    # #foo=) and raises UnknownOptionError if the attribute does not exist.
    def set_attributes(options)
      options.each_pair do |option, value|
        setter = "#{option}="

        if respond_to? setter
          send(setter, value)
        else
          raise UnknownOptionError, "#{self.class.name} does not support option #{option.inspect}."
        end
      end
    end

  end
end
