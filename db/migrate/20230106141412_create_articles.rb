# frozen_string_literal: true

class CreateArticles < ActiveRecord::Migration[7.0]
  def change
    create_table :articles do |t|
      t.string :title
      t.text :content_raw
      t.text :content
      t.string :status

      t.timestamps
    end
  end
end
