# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# bundle exec rake db:seed
100.times do |index|
  Chewy.strategy(:atomic) do
    Article.create(
      title: "Article with Index: #{index.next}",
      content: "Some Content of the Article with an Index: #{index.next}"
    )
    puts "Article with Index: #{index.next} is created"
  end
end
