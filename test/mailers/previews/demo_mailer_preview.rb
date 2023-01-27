# Preview all emails at http://localhost:3000/rails/mailers/demo_mailer
class DemoMailerPreview < ActionMailer::Preview
  # Accessible from  http://localhost:3000/rails/mailers/demo_mailer/welcome_email
  def welcome_email
    DemoMailer.welcome_email
  end
end
