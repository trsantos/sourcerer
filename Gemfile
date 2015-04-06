source 'https://rubygems.org'

ruby '2.2.1'

gem 'rails'
gem 'sass-rails'
gem 'uglifier'
gem 'coffee-rails'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder'
gem 'bcrypt'
gem 'foundation-rails'
gem 'faker'
gem 'feedjira'
gem 'opml_saw', :git => "git://github.com/feedbin/opml_saw.git", :branch => "master"
#gem 'open_uri_redirections'
gem 'sdoc', group: :doc

group :development, :test do
  gem 'sqlite3'
  gem 'byebug'
# gem 'web-console'
  gem 'spring'
end

group :test do
  gem 'minitest-reporters'
  gem 'mini_backtrace'
end

group :production do
  gem 'pg'
  gem 'rails_12factor'
  gem 'rack-timeout'
  gem 'unicorn'
end
