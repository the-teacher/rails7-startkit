# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/demo
class DemoPreview < ActionMailer::Preview
  # http://localhost:3000/rails/mailers/demo/welcome_email
  def welcome_email
    DemoMailer.welcome_email
  end
end
