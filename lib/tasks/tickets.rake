namespace :tickets do
  desc "Send daily email reminders for open tickets"
  task send_open_ticket_reminders: :environment do
    puts "Starting to send open ticket reminders at #{Time.now}"
    Rails.logger.info "Starting to send open ticket reminders"
    
    begin
      result = TicketMailer.send_open_ticket_reminders
      puts "Successfully sent reminders: #{result}"
    rescue => e
      puts "Error sending reminders: #{e.message}"
      puts e.backtrace.join("\n")
      raise e # Re-raise to ensure whenever gem sees the failure
    end
    
    puts "Completed sending open ticket reminders at #{Time.now}"
    Rails.logger.info "Completed sending open ticket reminders"
  end

  desc "Run open ticket reminders manually (for testing)"
  task test_open_ticket_reminders: :environment do
    puts "🧪 TESTING MODE: Sending open ticket reminders..."
    
    # Override email recipient for testing
    ENV['MAILER_TEST_RECIPIENT'] = ENV.fetch('TEST_EMAIL', 'your-email@example.com')
    
    # Run the regular task
    Rake::Task['tickets:send_open_ticket_reminders'].invoke
    
    puts "Testing complete. Emails would have been sent to: #{ENV['MAILER_TEST_RECIPIENT']}"
  end
end