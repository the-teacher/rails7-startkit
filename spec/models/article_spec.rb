# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Article, type: :model do
  it 'creates an article' do
    Article.create(
      title: 'ABC',
      content_raw: 'test content'
    )
    expect(Article.count).to eq(1)
  end

  it 'processes content_raw in content' do
    article = Article.create(
      title: 'Article title',
      content_raw: '<h1>test content<h1>'
    )
    expect(article.content).to eq('test content')
  end

  context 'negative cases' do
    it 'fails if title is of whitespaces ' do
      article = Article.create(
        title: '        ',
        content_raw: '<h1>test content<h1>'
      )

      expect(
        article.errors.messages[:title]
      ).to eq(["can't be blank"])
    end

    it 'fails if article title length less than 3 symbols' do
      article = Article.create(
        title: 'AB',
        content_raw: 'test content'
      )

      expect(
        article.errors.messages[:title]
      ).to eq(['is too short (minimum is 3 characters)'])
    end
  end
end
