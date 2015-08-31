source 'https://rubygems.org'

ruby '2.2.3'

### Default gems ###

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails'
# Use SCSS for stylesheets
gem 'sass-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails'
# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', group: :doc
# Use ActiveModel has_secure_password
gem 'bcrypt'

### end ###

gem 'jquery-turbolinks'
gem 'foundation-rails'
gem 'feedjira'
gem 'opml_saw', git: 'git://github.com/feedbin/opml_saw.git', branch: 'master'
gem 'sidekiq'
gem 'sinatra', require: nil
gem 'paypal-sdk-rest'
gem 'font-awesome-sass'

group :development, :test do
  gem 'sqlite3'
  gem 'byebug'
  gem 'web-console'
  gem 'spring'
  gem 'faker'
  # gem 'rack-mini-profiler'
  gem 'rubocop', require: false
end

group :test do
end

group :production do
  gem 'pg'
  gem 'rails_12factor'
  gem 'puma'
end
