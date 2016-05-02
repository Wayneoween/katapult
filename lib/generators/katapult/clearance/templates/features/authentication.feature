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

    When I fill in "Email" with "henry@example.com"
      And I press "Request Instructions"
    Then an email should have been sent with:
      """
      From: system@example.com
      To: henry@example.com
      Subject: Change your password

      Someone, hopefully you, requested we send you a link to change
  your password:
      """

    When I follow the first link in the email
    Then I should be on the new password page for the user above
      And I should see "Reset Password"

    When I fill in "Password" with "new-password"
      And I press "Update Password"
    Then I should see "Password updated" within the flash
      And I should be on the homepage
