namespace :db do
  desc 'Checks if database exists and is accessible'
  task exists: :environment do
    # First try with DATABASE_URL if available
    if ENV['DATABASE_URL'].present?
      ActiveRecord::Base.connection_db_config
      puts 'Checking database with connection URL...'
    else
      # Fall back to regular config
      puts 'Checking database with regular connection...'
    end

    # Try to establish connection
    ActiveRecord::Base.establish_connection
    ActiveRecord::Base.connection
    puts 'Database exists and is accessible'
    exit 0
  rescue ActiveRecord::NoDatabaseError
    puts 'Database does not exist'
    exit 1
  rescue StandardError => e
    puts "Error checking database: #{e.message}"
    puts e.backtrace.first(5).join("\n") if Rails.env.development?
    exit 1
  end
end
