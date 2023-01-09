class ArticlesController < ApplicationController
  def index
    @articles = Article.first(5)

    # https://freelancing-gods.com/thinking-sphinx/v5/searching.html
    query = ThinkingSphinx::Query.escape('Article with an Index: 1')
    @sphinx_articles = Article.search(
      query,
      order: 'title ASC'
    )
  end
end
