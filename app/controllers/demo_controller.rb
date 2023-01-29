class DemoController < ApplicationController
  def index
    # Example of ElasticSearch/Chewy search
    @search_query = params[:search] || 'Article'
    @found_articles = ArticlesIndex
                      .query(
                        query_string: {
                          query: @search_query,
                          fields: %i[title content]
                        }
                      )
                      .per(3)
                      .page params[:page]

    @articles = Article.order(:title).page params[:page]
  end
end
