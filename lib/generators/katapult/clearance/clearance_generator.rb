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
        # invoke 'clearance:install'
        # run 'bundle exec rails g clearance:install'
        generate 'clearance:install'
      end

      def require_login
        file = 'app/controllers/application_controller.rb'
        insert_into_file file, <<-CONTENT, after: "Clearance::Controller\n"

  before_action :require_login
        CONTENT
      end

      def overwrite_clearance_controllers
        template 'app/controllers/passwords_controller.rb'
      end

      def create_clearance_views
        directory 'app/views/clearance_mailer'
        directory 'app/views/passwords'
        directory 'app/views/sessions'
      end

      def install_backdoor
        # This creepy indentation leads to correct formatting in the file
        application <<-CONTENT, env: 'test'
# Enable quick-signin in tests: `visit homepage(as: User.last!)`
  config.middleware.use Clearance::BackDoor', env: 'test'
        CONTENT
      end

      def create_initializer
        template 'config/initializers/clearance.rb', force: true
      end

      def create_routes
        route <<-ROUTES
resources :users do
    resource :password, controller: 'passwords',
      only: %i[edit update]
  end

  # Clearance
  get '/login', to: '/clearance/sessions#new', as: 'sign_in'
  resource :session, controller: '/clearance/sessions', only: [:create]
  resources :passwords, controller: 'passwords', only: [:create, :new]
  delete '/logout', to: '/clearance/sessions#destroy', as: 'sign_out'
        ROUTES
      end

      def create_authentication_feature
        template 'features/authentication.feature'
      end

    end
  end
end
