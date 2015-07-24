source 'https://rubygems.org'

ruby '2.2.2'

gem 'rails'
gem 'sass-rails'
gem 'uglifier'
gem 'coffee-rails'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jquery-turbolinks'
gem 'jbuilder'
gem 'sdoc', group: :doc
gem 'bcrypt'
gem 'foundation-rails'
gem 'feedjira'
gem 'opml_saw', git: 'git://github.com/feedbin/opml_saw.git', branch: 'master'
gem 'sidekiq'
gem 'sinatra', require: nil
gem 'normalize-rails'
gem 'mousetrap-rails'
gem 'paypal-sdk-rest'

group :development, :test do
  gem 'sqlite3'
  gem 'byebug'
  gem 'web-console'
  gem 'spring'
  gem 'faker'
  # gem 'rack-mini-profiler'
  gem 'rubocop', require: false
  gem 'pry'
  gem 'pry-doc'
end

group :test do
  gem 'minitest-reporters'
  gem 'mini_backtrace'
end

group :production do
  gem 'pg'
  gem 'rails_12factor'
  gem 'puma'
end
