class Movie < ApplicationRecord
  after_create_commit { broadcast_prepend_to('movies', partial: 'movies/movie', locals: { movie: self }) }
  after_update_commit do
    broadcast_replace_to('movies', target: "movie_#{id}", partial: 'movies/movie', locals: { movie: self })
  end
  after_destroy do
    broadcast_remove_to('movies', target: "movie_#{id}")
  end
end
