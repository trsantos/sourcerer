desc 'Restart worker dyno (for Heroku)'
task restart_worker_dyno: :environment do
  if ENV['HEROKU_AUTH_TOKEN']
    heroku = PlatformAPI.connect_oauth(ENV['HEROKU_AUTH_TOKEN'])
    heroku.dyno.restart(ENV['HEROKU_APP_NAME'], 'worker.1')
  end
end
