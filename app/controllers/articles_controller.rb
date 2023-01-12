class ArticlesController < ApplicationController
  def index
    # Example of ElasticSearch/Chewy search
    @search_query = 'stench'
    @found_articles = ArticlesIndex
      .query(
        query_string: {
          query: @search_query,
          fields: [:title, :content]
      })
      .highlight({
        pre_tags: ['<b>'],
        post_tags: ['</b>'],
        fields: {
          title: {},
          content: {}
        }
      })
      .limit(3)

    @articles = Article.first(3)
  end
end
