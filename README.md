# Support Ticketing System Backend

A robust GraphQL API backend for a support ticketing system built with Ruby on Rails. This system allows customers to create support tickets, add comments, and upload attachments. Agents can manage tickets, generate reports, and efficiently handle customer inquiries.

## Features

- GraphQL API with mutations and queries for all operations
- JWT-based authentication and authorization
- Role-based access control (Customer vs Agent)
- Support ticket management
- Ticket commenting system
- File attachments for tickets
- CSV export functionality for tickets
- Scheduled reminders for agents with open tickets

## Technology Stack

- Ruby 3.2.2
- Rails 7.1.5
- PostgreSQL database
- GraphQL API using graphql-ruby
- Active Storage for file attachments
- JWT for authentication
- RSpec for testing

## Setup Instructions

### Prerequisites

- Ruby 3.2.2
- PostgreSQL
- Node.js and Yarn (for GraphiQL in development)

### Installation

1. Clone the repository
   ```bash
   git clone https://github.com/Davidosky007/support-ticketing-backend.git
   cd support-ticketing-backend
   ```

2. Install dependencies
   ```bash
   bundle install
   ```

3. Setup environment variables
   Create a `.env` file in the root directory with the following variables:
   ```
   DATABASE_USERNAME=your_postgres_username
   DATABASE_PASSWORD=your_postgres_password
   RAILS_MASTER_KEY=your_rails_master_key
   
   # Email Configuration
   SMTP_SERVER=smtp.example.com
   SMTP_PORT=587
   SMTP_USERNAME=your_email@example.com
   SMTP_PASSWORD=your_email_password
   MAIL_FROM=your_email@example.com
   MAILER_TEST_RECIPIENT=test_recipient@example.com
   ```

4. Database setup
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed  # Optional: to create sample data
   ```

5. Start the server
   ```bash
   rails s
   ```
	1. The GraphQL API will be accessible at http://localhost:3000/graphql for local development and at https://support-ticketing-backend.onrender.com/graphql for the production environment.

## Running with Docker

You can run the application using Docker for easy setup and deployment.

### Build the Docker image

```bash
docker build -t support-ticketing-backend .
```

### Run the application

You need a PostgreSQL database running and accessible to the container. You can use Docker Compose or run Postgres separately.

#### Example: Run with Docker Compose

Create a `docker-compose.yml` file like:

```yaml
version: '3.8'
services:
  db:
    image: postgres:15
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: support_ticketing
    ports:
      - "5432:5432"
    volumes:
      - db_data:/var/lib/postgresql/data

  app:
    build: .
    command: ./bin/rails server -b 0.0.0.0
    ports:
      - "3000:3000"
    environment:
      DATABASE_USERNAME: postgres
      DATABASE_PASSWORD: postgres
      DATABASE_HOST: db
      DATABASE_NAME: support_ticketing
      RAILS_ENV: development
      # Add other environment variables as needed
    depends_on:
      - db
    volumes:
      - .:/rails

volumes:
  db_data:
```

Then run:

```bash
docker-compose up --build
```

The Rails app will be available at [http://localhost:3000](http://localhost:3000).

### Environment Variables

- You can use a `.env` file in the project root for environment variables (see the example in the **Installation** section).
- Make sure to set `DATABASE_USERNAME`, `DATABASE_PASSWORD`, `DATABASE_HOST`, and `DATABASE_NAME` for Docker.

### Database Setup

The entrypoint script will automatically run `rails db:prepare` on container startup, so migrations and setup are handled for you.

## Database Schema

The application uses PostgreSQL with the following main tables:

- **users**: Stores user information with role-based distinctions (customer/agent)
- **tickets**: Core table for support tickets with subject, description, and status
- **comments**: User comments on tickets
- **ticket_assignments**: Records of agent assignments to tickets
- **active_storage_attachments/blobs**: For file attachments

Database schema migrations are located in `db/migrate/` directory, and the current schema can be viewed in `db/schema.rb`.

### Entity Relationship Diagram (ERD)

Below is the Entity Relationship Diagram showing the database structure and relationships:

![Support Ticketing System ERD](/app/assets/ERD_NEW.png)

### Key Relationships:

- A user can have many tickets (as customer)
- A user can have many assigned tickets (as agent)
- A ticket belongs to a customer and optionally to an agent
- A ticket has many comments
- A ticket has many attachments (via Active Storage)
- A comment belongs to a user and a ticket

## GraphQL Schema

The GraphQL schema defines types, queries, and mutations for interacting with the API:

- **Types**: User, Ticket, Comment, TicketAssignment, and Attachment
- **Queries**: For fetching users, tickets, and related data
- **Mutations**: For authentication, creating tickets, adding comments, etc.

The GraphQL schema definition is located in `app/graphql/` directory. You can explore the schema using GraphiQL in development at `http://localhost:3000/graphiql`.

### Key GraphQL Operations:

- **Authentication**: Login and register mutations
- **Ticket Management**: Create, update status, assign tickets
- **Comments**: Add comments to tickets
- **File Uploads**: Upload attachments to tickets
- **Reporting**: Generate CSV exports of tickets

## Email Functionality

The application includes email functionality for:

- Sending daily open ticket summaries to agents
- Notification emails for ticket updates
- Alerts for tickets requiring attention

Email configuration is managed through environment variables and can be customized in production and development environments. The application uses ActionMailer with SMTP for email delivery.

### Email Configuration

In development, emails can be tested using local SMTP settings or third-party services like Gmail. In production, it's recommended to use a dedicated email service like SendGrid, Mailgun, or Amazon SES.

The application uses the following environment variables for email configuration:

```
SMTP_SERVER=smtp.example.com
SMTP_PORT=587
SMTP_USERNAME=your_email@example.com
SMTP_PASSWORD=your_email_password
MAIL_FROM=your_email@example.com
MAILER_TEST_RECIPIENT=test_recipient@example.com
```

## Testing

The application includes comprehensive test coverage using RSpec:

- **Unit Tests**: For models, GraphQL types, and business logic
- **Integration Tests**: For GraphQL queries and mutations
- **System Tests**: For end-to-end workflows

To run the tests:

```bash
bundle exec rspec
```

Generate test coverage report:

```bash
COVERAGE=true bundle exec rspec
```

## Development Workflow

1. Create a new branch for each feature or bug fix
2. Write tests before implementing changes
3. Ensure all tests pass before submitting a pull request
4. Follow the Rails convention for code organization

## Deployment

The application is configured for deployment to Heroku:

```bash
heroku create
git push heroku main
heroku run rails db:migrate
```

## Frontend Repository

The frontend React application repository is available at:
[https://github.com/yourusername/support-ticketing-frontend](https://github.com/yourusername/support-ticketing-frontend)

## License

This project is licensed under the MIT License - see the LICENSE file for details.
