class ArticlesController < ApplicationController
  def index
    @articles = Article.first(20)
  end
end
