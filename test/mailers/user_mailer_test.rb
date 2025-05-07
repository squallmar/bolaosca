require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "boas_vindas" do
    mail = UserMailer.boas_vindas
    assert_equal "Boas vindas", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
