// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import ArticlesIndex from './articlesIndex'
import TheSearchHighlight from './theSearchHighlight'

console.log("Hello World! This is `importmap` entry point")

ArticlesIndex.init()
TheSearchHighlight.init('.the-search-highlight')
