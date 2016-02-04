desc 'Update ALL feeds in database'
task update_all_feeds: :environment do
  return if (Time.current.hour.modulo 3) == 0
  if ENV['HEROKU_AUTH_TOKEN']
    heroku = PlatformAPI.connect_oauth(ENV['HEROKU_AUTH_TOKEN'])
    heroku.dyno.restart(ENV['HEROKU_APP_NAME'], 'worker.1')
  end
  Feed.update_all_feeds
end
