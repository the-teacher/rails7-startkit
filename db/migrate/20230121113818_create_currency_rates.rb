# frozen_string_literal: true

class CreateCurrencyRates < ActiveRecord::Migration[7.0]
  def change
    create_table :currency_rates do |t|
      t.string :from
      t.string :to
      t.float :rate

      t.timestamps
    end
  end
end
