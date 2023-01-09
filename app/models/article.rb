# rails g model Article title:string content:text status:string
# rake db:migrate
#
class Article < ApplicationRecord
  # ElasticSearch / Chewy
  update_index('articles') { self }
end
