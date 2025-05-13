require 'rails_helper'

RSpec.describe 'Ticket Lifecycle', type: :request do
  let(:customer) { create(:user, :customer) }
  let(:agent) { create(:user, :agent) }
  let(:customer_token) { generate_token_for(customer) }
  let(:agent_token) { generate_token_for(agent) }
  
  it 'handles the complete lifecycle of a ticket' do
    # 1. Customer creates a ticket
    create_ticket_query = <<~GQL
      mutation($subject: String!, $description: String!) {
        createTicket(input: {
          subject: $subject
          description: $description
        }) {
          ticket {
            id
            subject
            status
          }
          errors
        }
      }
    GQL
    
    post '/graphql', 
      params: {
        query: create_ticket_query,
        variables: { 
          subject: "Integration Test Ticket", 
          description: "This is a test of the complete ticket lifecycle." 
        }
      },
      headers: { 'Authorization' => "Bearer #{customer_token}" }
    
    json = JSON.parse(response.body)
    ticket_id = json['data']['createTicket']['ticket']['id']
    expect(ticket_id).to be_present
    
    # 2. Agent assigns the ticket to themselves
    assign_ticket_query = <<~GQL
      mutation($ticketId: ID!) {
        assignTicket(input: {
          ticketId: $ticketId
        }) {
          ticket {
            id
            status
            agent {
              id
            }
          }
          errors
        }
      }
    GQL
    
    post '/graphql', 
      params: {
        query: assign_ticket_query,
        variables: { ticketId: ticket_id }
      },
      headers: { 'Authorization' => "Bearer #{agent_token}" }
    
    json = JSON.parse(response.body)
    expect(json['data']['assignTicket']['ticket']['agent']['id'].to_i).to eq(agent.id)
    
    # 3. Agent adds a comment
    add_comment_query = <<~GQL
      mutation($ticketId: ID!, $content: String!) {
        createComment(input: {
          ticketId: $ticketId
          content: $content
        }) {
          comment {
            id
            content
            user {
              id
              role
            }
          }
          errors
        }
      }
    GQL
    
    post '/graphql', 
      params: {
        query: add_comment_query,
        variables: { 
          ticketId: ticket_id,
          content: "I'll help you with this issue."
        }
      },
      headers: { 'Authorization' => "Bearer #{agent_token}" }
    
    json = JSON.parse(response.body)
    expect(json['data']['createComment']['comment']).to be_present
    
    # 4. Customer responds
    post '/graphql', 
      params: {
        query: add_comment_query,
        variables: { 
          ticketId: ticket_id,
          content: "Thank you for your help!"
        }
      },
      headers: { 'Authorization' => "Bearer #{customer_token}" }
    
    json = JSON.parse(response.body)
    expect(json['data']['createComment']['comment']).to be_present
    
    # 5. Agent uploads a file attachment
    upload_query = <<~GQL
      mutation($ticketId: ID!, $file: String!, $filename: String!, $contentType: String!) {
        uploadAttachment(input: {
          ticketId: $ticketId
          file: $file
          filename: $filename
          contentType: $contentType
        }) {
          success
          attachment {
            id
            filename
          }
          errors
        }
      }
    GQL
    
    file_content = "This is a solution document"
    base64_content = Base64.strict_encode64(file_content)
    
    post '/graphql', 
      params: {
        query: upload_query,
        variables: { 
          ticketId: ticket_id,
          file: base64_content,
          filename: "solution.txt",
          contentType: "text/plain"
        }
      },
      headers: { 'Authorization' => "Bearer #{agent_token}" }
    
    json = JSON.parse(response.body)
    expect(json['data']['uploadAttachment']['success']).to be true
    
    # 6. Agent closes the ticket
    close_ticket_query = <<~GQL
      mutation($ticketId: ID!) {
        updateTicketStatus(input: {
          ticketId: $ticketId
          status: "closed"
        }) {
          ticket {
            id
            status
          }
          errors
        }
      }
    GQL
    
    post '/graphql', 
      params: {
        query: close_ticket_query,
        variables: { ticketId: ticket_id }
      },
      headers: { 'Authorization' => "Bearer #{agent_token}" }
    
    json = JSON.parse(response.body)
    expect(json['data']['updateTicketStatus']['ticket']['status']).to eq('CLOSED')
    
    # 7. Customer verifies the ticket is closed
    get_ticket_query = <<~GQL
      query($id: ID!) {
        ticket(id: $id) {
          id
          subject
          status
          comments {
            content
            user {
              role
            }
          }
        }
      }
    GQL
    
    post '/graphql', 
      params: {
        query: get_ticket_query,
        variables: { id: ticket_id }
      },
      headers: { 'Authorization' => "Bearer #{customer_token}" }
    
    json = JSON.parse(response.body)
    ticket = json['data']['ticket']
    expect(ticket['status']).to eq('CLOSED')
    expect(ticket['comments'].size).to eq(2)
  end
  
  private
  
  def generate_token_for(user)
    payload = {
      user_id: user.id,
      exp: 24.hours.from_now.to_i
    }
    
    JWT.encode(payload, Rails.application.credentials.secret_key_base, 'HS256')
  end
end