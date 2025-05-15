require 'csv'

namespace :tickets do
  desc 'Generate working CSV file from actual database tickets'
  task generate_csv: :environment do
    puts 'Generating CSV from actual CLOSED tickets in database...'

    # Get all closed tickets (using the correct capitalization now)
    closed_tickets = Ticket.where(status: 'CLOSED')
    puts "Found #{closed_tickets.count} tickets with status 'CLOSED'"

    # List them for verification
    if closed_tickets.any?
      puts "\nTickets that will be included in CSV:"
      closed_tickets.each do |ticket|
        puts "  ID: #{ticket.id}, Subject: #{ticket.subject}, Created: #{ticket.created_at}"
      end

      # Create the CSV file
      timestamp = Time.now.to_i
      filename = "working_closed_tickets_#{timestamp}.csv"
      filepath = Rails.root.join('tmp', filename)

      CSV.open(filepath, 'w') do |csv|
        csv << %w[id subject description status customer_email agent_email created_at updated_at]

        closed_tickets.each do |ticket|
          # Get customer and agent emails - using the user association instead of customer
          customer_email = ticket.user&.email || 'unknown'
          agent_email = ticket.agent&.email || 'unknown'

          csv << [
            ticket.id,
            ticket.subject,
            ticket.description,
            ticket.status,
            customer_email,
            agent_email,
            ticket.created_at,
            ticket.updated_at
          ]
        end
      end

      puts "\nSuccessfully created CSV file: #{filepath}"
      puts "Try downloading this file at: /downloads/#{filename}"

      # Also display GraphQL query to use
      puts "\nUse this GraphQL mutation to test CSV generation:"
      puts %(
mutation {
  generateTicketsCsv(input: {}) {
    url
    errors
  }
}
      )
    else
      puts "\nNo CLOSED tickets found after fixing capitalization."
      puts "Let's create a sample CLOSED ticket for testing..."

      # Create a test ticket
      customer = User.where(role: 'customer').first
      agent = User.where(role: 'agent').first

      if customer && agent
        test_ticket = Ticket.create(
          subject: 'Test Closed Ticket',
          description: 'This is a test ticket created to verify CSV generation.',
          status: 'CLOSED',
          customer: customer,
          agent: agent
        )

        puts "Created test ticket with ID: #{test_ticket.id}"
        puts 'Run this task again to generate a CSV with this ticket.'
      else
        puts "ERROR: Couldn't find customer and agent users to create a test ticket."
        puts 'Please create users first.'
      end
    end
  end
end
