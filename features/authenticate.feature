Feature: Add authentication to an application

  Background:
    Given a pristine Rails application
    And I install katapult
    And I generate katapult basics


  Scenario: Authenticate with the User model
    When I overwrite "lib/katapult/application_model.rb" with:
      """
      model 'User'
      authenticate system_email: 'system@example.com'
      """
    And I successfully transform the application model
    Then the file "Gemfile" should contain "gem 'clearance'"
    And the file "app/controllers/application_controller.rb" should contain:
      """
        before_action :require_login
        include Clearance::Controller
      """
    And the file "app/controllers/passwords_controller.rb" should contain exactly:
      """
      class PasswordsController < Clearance::PasswordsController

        def update
          @user = find_user_for_update

          if @user.update_password password_reset_params
            sign_in @user
            flash[:notice] = 'Password successfully changed' # <<- added
            redirect_to url_after_update
          else
            flash_failure_after_update
            render template: 'passwords/edit'
          end
        end

      end
      """
    And the file "app/controllers/users_controller.rb" should contain:
      """
            email
            password
      """
    And the file "app/views/users/_form.html.haml" should contain:
      """
          %dt
            = form.label :email
          %dd
            = form.text_field :email
          %dt
            = form.label :password
          %dd
            = form.text_field :password
      """
    And the file "app/views/clearance_mailer/change_password.html.haml" should contain exactly:
      """
      %p
        To reset your password, please follow this link:

      %p
        = link_to 'Change password',
          edit_user_password_url(@user, token: @user.confirmation_token.html_safe)

      """
    And the file "app/views/clearance_mailer/change_password.text.erb" should contain exactly:
      """
      To reset your password, please follow this link:

      <%= edit_user_password_url(@user, token: @user.confirmation_token.html_safe) %>
      """
    And the file "app/views/passwords/create.html.haml" should contain exactly:
      """
      %h1
        Password Reset Instructions Sent

      %p
        We've sent you an email with instructions on how to reset your password.
      """
    And the file "app/views/passwords/edit.html.haml" should contain exactly:
      """
      %h1
        Reset Password

      %p
        Choose your new password:

      = form_for :password_reset,
        url: user_password_path(@user, token: @user.confirmation_token),
        html: { method: :put } do |form|

        .form-group
          = form.label :password
          = form.password_field :password, class: 'form-control',
            placeholder: 'New Password'

        = form.submit 'Update Password', class: 'btn btn-primary'
      """
    And the file "app/views/passwords/new.html.haml" should contain exactly:
      """
      %h1
        Password Reset

      %p
        Please enter your email address. We will send you instructions on how
        to reset your password.

      = form_for :password, url: passwords_path do |form|
        .form-group
          = form.label :email
          = form.email_field :email, class: 'form-control',
            placeholder: 'Email Address'

        = form.submit 'Request Instructions', class: 'btn btn-primary'
      """
    And the file "app/views/sessions/new.html.haml" should contain exactly:
      """
      %h1
        Please sign in

      = form_for :session, url: session_path do |form|
        .form-group
          = form.label :email
          = form.email_field :email, class: 'form-control',
            placeholder: 'Email Address', required: true, autofocus: true

        .form-group
          = form.label :password
          = form.password_field :password, class: 'form-control', required: true,
            placeholder: 'Password'

        %p
          = form.submit 'Sign in', class: 'btn btn-primary'

        %p
          = link_to 'Forgot password', new_password_path, class: 'text-muted'
      """
    And the file "config/environments/test.rb" should contain:
      """
        config.middleware.use Clearance::BackDoor
      """
    And the file "config/initializers/clearance.rb" should contain exactly:
      """
      Clearance.configure do |config|
        config.allow_sign_up = false
        # config.cookie_domain = '.example.com'
        # config.cookie_expiration = lambda { |cookies| 1.year.from_now.utc }
        # config.cookie_name = 'remember_token'
        # config.cookie_path = '/'
        config.routes = false
        # config.httponly = true
        config.mailer_sender = 'system@example.com'
        # config.password_strategy = Clearance::PasswordStrategies::BCrypt
        # config.redirect_url = '/'
        # config.secure_cookie = true
        # config.sign_in_guards = []
        # config.user_model = User
      end
      """
    And the file "config/routes.rb" should contain:
      """
        resources :users do
          resource :password, controller: 'passwords',
            only: %i[edit update]
        end

        # Clearance
        get '/login', to: '/clearance/sessions#new', as: 'sign_in'
        resource :session, controller: '/clearance/sessions', only: [:create]
        resources :passwords, controller: 'passwords', only: [:create, :new]
        delete '/logout', to: '/clearance/sessions#destroy', as: 'sign_out'
      """
    And there should be a migration with:
      """
      class AddClearanceToUsers < ActiveRecord::Migration
        def self.up
          change_table :users do |t|
            t.string :encrypted_password, limit: 128
            t.string :confirmation_token, limit: 128
            t.string :remember_token, limit: 128
          end

          add_index :users, :email
          add_index :users, :remember_token

          users = select_all("SELECT id FROM users WHERE remember_token IS NULL")

          users.each do |user|
            update <<-SQL
              UPDATE users
              SET remember_token = '#{Clearance::Token.new}'
              WHERE id = '#{user['id']}'
            SQL
          end
        end

        def self.down
          change_table :users do |t|
            t.remove :encrypted_password, :confirmation_token, :remember_token
          end
        end
      end
      """
    And the file "features/authentication.feature" should contain exactly:
      """
      Feature: Everything about user authentication

        Scenario: Login is required to visit the homepage
          When I go to the homepage
          Then I should see "Please sign in to continue" within the flash
            And I should be on the sign-in form


        Scenario: Login
          Given there is a user with the name "Henry" and the email "henry@example.com" and the password "password"

          When I go to "/admin"
          Then I should be on the sign-in form
            And I should see "Please sign in"

          # Wrong email
          When I fill in "Email" with "nonsense"
            And I fill in "Password" with "password"
            And I press "Sign in"
          Then I should see "Bad email or password" within the flash
            And I should see "Please sign in"

          # Wrong password
          When I fill in "Email" with "admin@example.com"
            And I fill in "Password" with "wrong"
            And I press "Sign in"
          Then I should see "Bad email or password" within the flash
            And I should see "Please sign in"

          # Correct credentials
          When I fill in "Email" with "henry@example.com"
            And I fill in "Password" with "password"
            And I press "Anmelden"
          Then I should be on the homepage


        Scenario: Logout
          Given there is a user with the name "Henry"
            And I am signed in as the user above

          When I follow "Sign out"
          Then I should be on the sign-in form

          # Logged out
          When I go to the homepage
          Then I should be on the sign-in form


        Scenario: Reset password as a signed-in user
          Given there is a user with the name "Henry" and the email "henry@example.com"
            And I sign in as the user above

          When I go to the homepage
            And I follow "Henry" within the current user
          Then I should be on the form for the user above

          When I fill in "Password" with "new-password"
            And I press "Save"
          Then I should be on the list of users

          When I follow "Sign out"
            And I fill in "Email" with "henry@example.com"
            And I fill in "Password" with "new-password"
            And I press "Sign in"
          Then I should be on the homepage
            And I should see "Signed in" within the flash


        Scenario: Reset password as a signed-out user
          Given there is a user with the name "Henry" and the email "henry@example.com"

          When I go to the sign-in form
            And I follow "Forgot password"
          Then I should be on the reset password page
            And I should see "Password Reset"
            And I should see "Bitte geben Sie Ihre E-Mail-Adresse ein"

          When I fill in "E-Mail-Adresse" with "vergesslich@example.de"
            And I press "Link anfordern"
          Then an email should have been sent with:
            '''
            From: system@ruv-newsroom.de
            To: vergesslich@example.de
            Subject: [R+V Newsroom] Passwort zurücksetzen

            Wenn Sie Ihr Passwort für den R+V Newsroom zurücksetzen möchten, öffnen Sie bitte diese Adresse in
            Ihrem Browser:


            '''
            And that email should have the following lines in the body:
            """
            Falls Sie Ihr Passwort nicht ändern möchten, können Sie diese E-Mail einfach
            löschen.
            """

          When I follow the first link in the email
          Then I should be on the new password page for the user above
            And I should see "Passwort zurücksetzen"

          When I fill in "Neues Passwort" with "new-password"
            And I press "Passwort festlegen"
          Then I should see "Neues Passwort erfolgreich festgelegt" within the flash
            And I should be on the backend
      """
