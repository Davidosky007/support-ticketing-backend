class EmailSchedulerWorker
  def perform
    loop do
      current_time = Time.now
      
      # Check if it's 9 AM
      if current_time.hour == 9 && current_time.min == 0
        Rails.logger.info "Triggering daily email reminders"
        begin
          Rake::Task['tickets:send_open_ticket_reminders'].invoke
          Rake::Task['tickets:send_open_ticket_reminders'].reenable
        rescue => e
          Rails.logger.error "Failed to send daily emails: #{e.message}"
        end
      end
      
      # Sleep for 60 seconds before checking again
      sleep 60
    end
  end
end