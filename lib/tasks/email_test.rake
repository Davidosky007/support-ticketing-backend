namespace :email do
  desc 'Test email delivery'
  task test: :environment do
    puts 'Testing email delivery...'

    recipient = ENV.fetch('MAILER_TEST_RECIPIENT', 'davidbassey428@gmail.com')

    begin
      result = ActionMailer::Base.mail(
        from: ENV.fetch('MAIL_FROM', 'davidosky1@gmail.com'),
        to: recipient,
        subject: 'Test Email from Support System',
        body: 'This is a test email to verify SMTP settings are working correctly.'
      ).deliver_now

      puts 'Email appears to have been sent successfully!'
      puts "Message ID: #{result.message_id}"
      puts "Check your inbox at: #{recipient}"
    rescue StandardError => e
      puts 'ERROR: Email delivery failed!'
      puts "Exception: #{e.class} - #{e.message}"
      puts e.backtrace.join("\n")
    end
  end
end
