# frozen_string_literal: true

# rails g model currency_rate
#   from:string
#   to:string
#   rate:float

# rails runner CurrencyRate.get
# rails runner 'CurrencyRate.get("KGS", "USD")'
# rails runner "CurrencyRate.get('USD', 'EUR')"

class CurrencyRate < ApplicationRecord
  API = 'https://api.exchangerate.host/latest'

  def self.get(from = 'USD', to = 'EUR')
    uri = URI(CurrencyRate::API + "?base=#{from}&symbols=#{to}")

    response = Net::HTTP.get(uri)
    response_obj = JSON.parse(response)

    create!(
      from:, to:,
      rate: response_obj['rates'][to]
    )

    puts "[#{DateTime.now.strftime('%d.%m.%Y %H.%M.%S')}]: " \
         "#{from}:#{to} currency rate: " + response_obj['rates'][to].to_s
  end
end
