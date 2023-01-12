# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# bundle exec rake db:seed

def p_tag(text)
  "<p>#{text}</p>\n"
end

STATUSES = [:draft, :published, :deleted]

100.times do |index|
  content = "Article ##{index.next}: " +
    p_tag(Faker::ChuckNorris.fact) +
    p_tag(Faker::Books::Lovecraft.paragraph) +
    p_tag(Faker::TvShows::BigBangTheory.quote)
    p_tag(Faker::TvShows::FinalSpace.quote)

  Chewy.strategy(:atomic) do
    Article.create(
      title: "Article with Index: #{index.next}",
      content_raw: content,
      content: content,
      status: STATUSES.shuffle.first
    )
    puts "Article ##{index.next} is created"
  end
end
