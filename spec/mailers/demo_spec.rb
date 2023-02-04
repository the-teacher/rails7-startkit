# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DemoMailer, type: :mailer do
  let(:mail) { DemoMailer.welcome_email }

  it 'renders the headers' do
    expect(mail.subject).to eq('Welcome to Rails 7. StartKit')
    expect(mail.to).to eq(['test@test.com'])
    expect(mail.from).to eq(['demo@rails7startkit.com'])
  end

  it 'renders the body' do
    expect(mail.body.encoded).to match('Welcome to Rails7. StartKit')
    expect(mail.body.encoded).to match('Thanks for using this project!')
  end
end
