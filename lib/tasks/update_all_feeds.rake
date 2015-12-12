desc 'Update ALL feeds in database'
task update_all_feeds: :environment do
  if Time.current.hour.modulo(1) == 0
    require 'thread/pool'
    pool = Thread.pool(7)
    Feed.find_each do |f|
      pool.process do
        f.update
        ActiveRecord::Base.connection.close
      end
    end
    pool.shutdown
  end
end
