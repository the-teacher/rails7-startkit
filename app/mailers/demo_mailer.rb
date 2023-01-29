# frozen_string_literal: true

# rails generate mailer demo
#
# DemoMailer.welcome_email.deliver!
class DemoMailer < ApplicationMailer
  default from: 'demo@rails7startkit.com'

  def welcome_email
    mail(
      to: 'test@test.com',
      subject: 'Welcome to Rails 7. StartKit'
    )
  end
end
