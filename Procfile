web: bundle exec puma -C config/puma.rb
worker: bundle exec bin/delayed_job -n 3 start && rake jobs:work
