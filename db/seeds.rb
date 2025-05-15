# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Seeds for support ticketing system

# Clear existing data to avoid duplicates
puts 'Cleaning database...'
Comment.destroy_all
Ticket.destroy_all
User.destroy_all
puts 'Database cleaned!'

# Create users with different roles
puts 'Creating users...'

# Create customers
customers = []
5.times do |i|
  customers << User.create!(
    name: "Customer #{i + 1}",
    email: "customer#{i + 1}@example.com",
    password: 'password123',
    role: :customer
  )
  puts "Created customer: #{customers.last.name}"
end

# Create agents
agents = []
3.times do |i|
  agents << User.create!(
    name: "Agent #{i + 1}",
    email: "agent#{i + 1}@example.com",
    password: 'password123',
    role: :agent
  )
  puts "Created agent: #{agents.last.name}"
end

# Create tickets with different statuses
puts 'Creating tickets...'

# Array of realistic ticket subjects
ticket_subjects = [
  'Unable to login to my account',
  'How do I reset my password?',
  'Website is loading slowly',
  'Payment not being processed',
  'Need to update my billing information',
  'Feature request: dark mode',
  'Mobile app crashes on startup',
  'Products not showing in cart',
  'Unable to checkout',
  'Discount code not working'
]

# Array of realistic ticket descriptions
ticket_descriptions = [
  "I've been trying to login for the past hour but keep getting an error message saying 'Invalid credentials'.",
  "I forgot my password and need to reset it. I don't see an option on the login page.",
  'Your website has been loading very slowly for the past few days. It takes almost 30 seconds to load the homepage.',
  "I'm trying to make a payment but the system keeps saying 'Transaction failed' after I enter my credit card details.",
  "I've moved recently and need to update my billing address in your system.",
  'I would love to see a dark mode option for your website. It would be easier on the eyes when using at night.',
  "Every time I try to open your app on my iPhone 13, it crashes immediately. I've reinstalled but still having issues.",
  'I added several items to my cart but when I go to checkout, my cart shows as empty.',
  "When I click the 'Complete Order' button, nothing happens. I've tried multiple browsers.",
  "I'm trying to use the discount code 'SUMMER25' but the system says it's invalid even though your email said it's active."
]

# Create 15 tickets across different states
15.times do |i|
  # Determine status (more open tickets than others for testing)
  status = case rand(10)
           when 0..5 then :open
           when 6..8 then :pending
           else :closed
           end

  # Select a random customer and subject/description
  customer = customers.sample
  subject = ticket_subjects[i % ticket_subjects.length]
  description = ticket_descriptions[i % ticket_descriptions.length]

  # Assign an agent to some tickets
  agent = status == :open ? nil : agents.sample

  # Create the ticket
  ticket = Ticket.create!(
    subject: subject,
    description: description,
    status: status,
    customer_id: customer.id,
    agent_id: agent&.id,
    agent_commented: %i[pending closed].include?(status)
  )

  puts "Created ticket ##{ticket.id} (#{ticket.status}): #{ticket.subject}"

  # Add comments to some tickets
  if %i[pending closed].include?(status)
    # Agent comment first
    Comment.create!(
      content: "Thank you for contacting us. I'll look into this issue for you.",
      user: agent,
      ticket: ticket
    )

    # Customer reply
    if rand(10) > 3 # 60% chance of customer reply
      Comment.create!(
        content: 'Thank you for your prompt response. Looking forward to a resolution.',
        user: customer,
        ticket: ticket
      )
    end

    # Agent follow-up for closed tickets
    if status == :closed
      Comment.create!(
        content: "I've resolved this issue. Please let us know if you need anything else.",
        user: agent,
        ticket: ticket
      )
    end

    puts "  Added #{ticket.comments.count} comments to ticket ##{ticket.id}"
  end

  # Add file attachments to some tickets (if using Active Storage)
  next unless rand(10) > 6 # 30% chance of having attachments

  # Uncomment and configure if you want to add real file attachments
  # In a real app, you would attach actual files like this:
  # ticket.attachments.attach(
  #   io: File.open(Rails.root.join('app', 'assets', 'images', 'sample.jpg')),
  #   filename: 'screenshot.jpg',
  #   content_type: 'image/jpeg'
  # )
  puts "  Would attach files to ticket ##{ticket.id} (commented out in seed file)"
end

puts 'Seed data created successfully!'

puts "\n======== GraphQL Testing Data ========"
puts 'You can now test your GraphQL API with the following data:'
puts "Customers: #{customers.map(&:email).join(', ')}"
puts "Agents: #{agents.map(&:email).join(', ')}"
puts "Open tickets: #{Ticket.open.count}"
puts "Pending tickets: #{Ticket.pending.count}"
puts "Closed tickets: #{Ticket.closed.count}"
puts "Total comments: #{Comment.count}"
puts "=======================================\n"

# Add sample data for testing CSV exports
# Instead of using namespace, define this as a method so it can be called
def create_csv_test_data
  # Find or create a customer
  customer = User.find_by(role: 'customer')
  unless customer
    puts 'Creating sample customer user...'
    customer = User.create!(
      name: 'Test Customer',
      email: 'customer@example.com',
      password: 'password123',
      role: 'customer'
    )
  end

  # Find or create an agent
  agent = User.find_by(role: 'agent')
  unless agent
    puts 'Creating sample agent user...'
    agent = User.create!(
      name: 'Test Agent',
      email: 'agent@example.com',
      password: 'password123',
      role: 'agent'
    )
  end

  puts 'Creating sample closed tickets...'
  5.times do |i|
    # Random date in the past month
    created_at = rand(1..30).days.ago
    closed_at = created_at + rand(1..5).days

    ticket = Ticket.create!(
      subject: "Sample Closed Ticket ##{i + 1}",
      description: "This is a sample ticket for testing CSV export. Issue #{i + 1}.",
      status: 'closed',
      customer_id: customer.id,
      agent_id: agent.id,
      created_at: created_at,
      updated_at: closed_at
    )

    # Add a comment from the customer
    Comment.create!(
      ticket: ticket,
      user: customer,
      content: 'I need help with this issue please.',
      created_at: created_at + 1.hour
    )

    # Add a comment from the agent
    Comment.create!(
      ticket: ticket,
      user: agent,
      content: "I've resolved this issue for you.",
      created_at: created_at + 2.hours
    )

    puts "Created ticket ##{ticket.id}: #{ticket.subject} (closed on #{closed_at.strftime('%Y-%m-%d')})"
  end

  puts 'Done! Created 5 sample closed tickets in the past month.'
end

# To avoid running this in production, only run in development or test
if Rails.env.development? || Rails.env.test?
  # Call the method directly
  create_csv_test_data
end
