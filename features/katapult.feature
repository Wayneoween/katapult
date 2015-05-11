Feature: Katapult in general

  Background:
    Given a pristine Rails application


  Scenario: Install katapult
    When I install katapult
    Then the file "lib/katapult/application_model.rb" should contain exactly:
      """
      # Here you define the fundamentals of your application.
      #
      # Add a model:
      # model 'customer' do |customer|
      #   customer.attr :name
      #   customer.attr :birth, type: :date
      #   customer.attr :email
      # end
      #
      # Add a web user interface:
      # wui 'customer' do |wui|
      #   wui.action :index
      #   wui.action :show
      #   wui.action :lock, scope: :member, method: :post
      # end
      #
      # Add navigation
      # navigation :main

      """


  Scenario: Generate basic files and settings
    Given I install katapult
    When I generate katapult basics
    Then the file ".ruby-version" should contain "2.1.5"
    And the file "Gemfile" should contain exactly:
      """
      source 'https://rubygems.org'

      # from original Gemfile
      gem 'rails', '4.2.1'
      gem 'mysql2'
      gem 'jquery-rails'
      gem 'jbuilder', '~> 2.0'
      gem 'katapult', path: '../../..'

      # engines
      gem 'haml-rails'

      # internal
      gem 'exception_notification'
      gem 'breach-mitigation-rails'

      # better coding
      gem 'modularity'
      gem 'edge_rider'
      gem 'andand'

      # models
      gem 'has_defaults'
      gem 'assignable_values'

      # gem 'carrierwave'
      # gem 'mini_magick'

      # gem 'spreadsheet'
      # gem 'vcard'

      # views
      # gem 'simple_form'
      # gem 'nested_form'
      gem 'will_paginate'
      gem 'makandra-navy', require: 'navy'

      # assets
      gem 'bootstrap-sass'
      gem 'sass-rails'
      gem 'autoprefixer-rails'
      gem 'coffee-rails'
      gem 'uglifier'
      gem 'compass-rails', '>= 2.0.4' # fixes "uninitialized constant Sprockets::SassCacheStore"
      gem 'compass-rgbapng'

      group :development do
        gem 'query_diet'
        gem 'better_errors'
        gem 'binding_of_caller'
        gem 'thin'

        gem 'guard-livereload', require: false
        gem 'rack-livereload'
        gem 'spring-commands-rspec'
        gem 'spring-commands-cucumber'
      end

      group :development, :test do
        gem 'byebug'
        gem 'factory_girl_rails'
        gem 'rspec-rails'
        gem 'spring'
      end

      group :test do
        gem 'parallel_tests'
        gem 'database_cleaner'
        gem 'timecop'
        gem 'launchy'

        gem 'capybara'
        gem 'cucumber-rails', require: false
        gem 'cucumber_factory'
        gem 'cucumber_spinner'
        gem 'selenium-webdriver'
        gem 'spreewald'

        gem 'rspec'
        gem 'shoulda-matchers', require: false
      end

      """

    And the file "config/database.yml" should contain exactly:
      """
      common: &common
        adapter: mysql2
        encoding: utf8
        username: katapult
        password: secret

      development:
        <<: *common
        database: katapult_test_app_development

      test: &test
        <<: *common
        database: katapult_test_app_test<%= ENV['TEST_ENV_NUMBER'] %>

      cucumber:
        <<: *test
      """
    And the file "config/database.sample.yml" should contain exactly:
      """
      common: &common
        adapter: mysql2
        encoding: utf8
        username: root
        password:

      development:
        <<: *common
        database: katapult_test_app_development

      test: &test
        <<: *common
        database: katapult_test_app_test<%= ENV['TEST_ENV_NUMBER'] %>

      cucumber:
        <<: *test

      """

    And the file "features/support/env-custom.rb" should contain:
      """
      require 'spreewald/all_steps'
      """
    And a file named "features/support/paths.rb" should exist
    And the file "spec/rails_helper.rb" should contain:
      """
      require 'rspec/rails'
      require 'shoulda/matchers'
      """



    # styles
    And the file "app/assets/stylesheets/application.css.sass" should contain:
      """
      @import compass
      @import bootstrap

      @import application/blocks/all

      """
    And the file "app/assets/stylesheets/application/blocks/_all.css.sass" should contain exactly:
      """
      @import items
      @import layout
      @import navigation
      @import tools

      """
    And a file named "app/assets/stylesheets/application/blocks/_items.css.sass" should exist
    And a file named "app/assets/stylesheets/application/blocks/_layout.css.sass" should exist
    And a file named "app/assets/stylesheets/application/blocks/_navigation.css.sass" should exist
    And a file named "app/assets/stylesheets/application/blocks/_tools.css.sass" should exist

    # And the file "config/deploy.rb" should contain exactly:
    #   """
    #   stages
    #   """
