# frozen_string_literal: true

# @articles = ArticlesIndex.query(
#   query_string: {
#     query: 'Article',
#     fields: [:title, :content],
#   }
# )
class ArticlesIndex < Chewy::Index
  index_scope Article

  field :title
  field :content
end
