require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  include Rails.application.routes.url_helpers

  test "email_confirmation" do
    user = users(:some_great_user)

    mail = UserMailer.email_confirmation(user, 'token')
    assert_equal "Ain't No Bracket Like It Email Confirmation", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match UserMailerHelper::EMAIL_CONFIRMATION_BASE_URL, mail.body.encoded
  end

  test "reset_password" do
    user = users(:some_great_user)

    mail = UserMailer.reset_password(user, 'token')
    assert_equal "Ain't No Bracket Like It Reset Password", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match UserMailerHelper::RESET_PASSWORD_BASE_URL, mail.body.encoded
  end

  test "password_changed" do
    user = users(:some_great_user)

    mail = UserMailer.password_changed(user)
    assert_equal "Ain't No Bracket Like It Password Changed", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["from@example.com"], mail.from
  end
end
