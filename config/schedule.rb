# Use this file to easily define all of your cron jobs.
# Learn more: http://github.com/javan/whenever

# Set the output to a log file for debugging
set :output, 'log/cron.log'

# Set the environment
set :environment, ENV['RAILS_ENV'] || 'development'

# Send daily open ticket reminders at 9 AM
every 1.day, at: '9:00 am' do
  rake 'tickets:send_open_ticket_reminders'
end

# Send a daily summary email at 10:00 AM (after the agent emails)
every 1.day, at: '10:00 am' do
  rake 'email:daily_summary'
end
