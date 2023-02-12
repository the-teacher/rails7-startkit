# frozen_string_literal: true

class DemoController < ApplicationController
  before_action :get_articles, only: %w[index articles_list articles_cache]

  def index
    render 'articles/articles_list'
  end

  def articles_list
    render 'articles/articles_list'
  end

  def articles_cache
    render 'articles/articles_cache'
  end

  # Example of ElasticSearch/Chewy search
  def articles_search
    @term = params[:search] || 'Article'

    @articles = ArticlesIndex
                .query(
                  query_string: {
                    query: @term,
                    fields: %i[title content]
                  }
                )
                .per(3)
                .page params[:page]

    render 'articles/articles_search'
  end

  private

  # rubocop:disable Naming/AccessorMethodName
  def get_articles
    @articles = Article.order(:title).page params[:page]
  end
  # rubocop:enable Naming/AccessorMethodName
end
