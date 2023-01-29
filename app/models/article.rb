# frozen_string_literal: true

# rails g model Article
#  title:string
#  content_raw:text
#  content:text
#  status:string

# rake db:migrate
#
class Article < ApplicationRecord
  # ElasticSearch / Chewy
  update_index('articles') { self }

  # Validations
  validates :title, presence: true, length: { minimum: 3 }

  # Kaminari. Pagination
  paginates_per 3

  # Take a raw content from a user and save it in `content_raw`.
  # But never render `content_raw` on a page. It is dangerous!
  # Process a content once `on save` and cut off dangerous tags.
  # Now you can render `content` field on a page with using `raw` helper
  # <%= raw article.content %>
  before_save :prepare_content

  # https://www.ruby-toolbox.com/projects/sanitize
  def prepare_content
    self.title = Sanitize.fragment(title, { elements: [] }).strip
    self.content = Sanitize.fragment(content_raw, Sanitize::Config::RESTRICTED).strip
  end
end
