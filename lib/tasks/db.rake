namespace :db do
  desc 'Checks if database exists'
  task exists: :environment do
    puts "Checking database in #{Rails.env} environment..."
    ActiveRecord::Base.connection
    puts 'Database exists'
    exit 0
  rescue ActiveRecord::NoDatabaseError
    puts 'Database does not exist'
    exit 1
  rescue StandardError => e
    puts "Error checking database: #{e.message}"
    exit 1
  end
end
