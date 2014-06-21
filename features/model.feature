@announce
Feature: Generate Models

  Background:
    Given a pristine Rails application with wheelie installed


  Scenario: Generate ActiveRecord Model
    When I overwrite "lib/wheelie/metamodel.rb" with:
      """
      metamodel 'Test' do |test|
        test.model 'Car'
      end
      """
    And I successfully render the metamodel
    Then the file "app/models/car.rb" should contain exactly:
      """
      class Car < ActiveRecord::Base
      end

      """
    And there should be a migration with:
      """
      class CreateCars < ActiveRecord::Migration
        def change
          create_table :cars do |t|

            t.timestamps
          end
        end
      end

      """
    And the file "spec/models/car_spec.rb" should contain exactly:
      """
      require 'rails_helper'

      describe Car do

      end

      """


  Scenario: Generate ActiveRecord Model with attributes
    When I overwrite "lib/wheelie/metamodel.rb" with:
      """
      metamodel 'Test' do |test|
        test.model 'Person' do |person|

          # Basic types
          person.attr :age, type: :integer
          person.attr :nick, type: :string
          person.attr :hobby # string is default

          # Special types
          person.attr :email # type is detected as email
          person.attr :income, type: :money
          person.attr :homepage, type: :url, default: 'http://www.makandra.de'
          person.attr :locked, type: :flag, default: false
        end
      end
      """
    And I successfully render the metamodel
    Then the file "app/models/person.rb" should contain exactly:
      """
      class Person < ActiveRecord::Base
        has_defaults({:homepage=>"http://www.makandra.de"})
        include DoesFlag[:locked, default: false]
      end

      """
    And there should be a migration with:
      """
      class CreatePeople < ActiveRecord::Migration
        def change
          create_table :people do |t|
            t.integer :age
            t.string :nick
            t.string :hobby
            t.string :email
            t.decimal :income, precision: 10, scale: 2
            t.string :homepage
            t.boolean :locked

            t.timestamps
          end
        end
      end

      """
    And the file "spec/models/person_spec.rb" should contain exactly:
      """
      require 'rails_helper'

      describe Person do
        it { is_expected.to_not be_locked }

        describe '#homepage' do
          it 'has a default' do
            expect( subject.homepage ).to eql("http://www.makandra.de")
          end
        end

      end

      """
    And the specs should pass


  Scenario: Get a helpful error message when an attribute has an unknown option
    When I overwrite "lib/wheelie/metamodel.rb" with:
      """
      metamodel 'Test' do |test|
        test.model 'Person' do |person|
          person.attr :x, invalid_option: 'here'
        end
      end
      """
    And I render the metamodel
    Then the output should contain "Wheelie::Attribute does not support option :invalid_option. (Wheelie::Element::UnknownOptionError)"


  Scenario: Specify assignable_values
    When I overwrite "lib/wheelie/metamodel.rb" with:
      """
      metamodel 'Test' do |test|
        test.model 'Person' do |person|
          person.attr :hobby, assignable_values: %w[soccer baseball], default: 'soccer', allow_blank: true
          person.attr :age, assignable_values: 9..99
        end
      end
      """
    And I successfully render the metamodel
    Then the file "app/models/person.rb" should contain exactly:
      """
      class Person < ActiveRecord::Base
        assignable_values_for :age, {} do
          9..99
        end
        assignable_values_for :hobby, {:allow_blank=>true, :default=>"soccer"} do
          ["soccer", "baseball"]
        end
      end

      """
    And the file "spec/models/person_spec.rb" should contain exactly:
      """
      require 'rails_helper'

      describe Person do

        describe '#hobby' do
          it 'has a default' do
            expect( subject.hobby ).to eql("soccer")
          end
        end

      end

      """
    And the specs should pass

