# 1. rake ts:configure
# 2. docker exec rails7app-sphinx-1 indexer --all --config /opt/sphinx/conf/sphinx.conf
# 3. Article.search('Article')
ThinkingSphinx::Index.define :article, :with => :active_record do
  indexes title, :sortable => true
  indexes content

  has created_at, updated_at
end
