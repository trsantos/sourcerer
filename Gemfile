source 'https://rubygems.org'

ruby '2.2.3'

### Default gems ###

gem 'rails'
gem 'sass-rails'
gem 'uglifier'
gem 'coffee-rails'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder'
gem 'sdoc', group: :doc
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
