# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'http://localhost:4200', 'https://support-ticketing-frontend.vercel.app/' # Update with your frontend app's URL

    resource '*',
             headers: :any,
             methods: %i[get post put patch delete options head]
  end

  allow do
    origins '*' # Or your frontend domain
    resource '/downloads/*',
             headers: :any,
             methods: [:get]
  end
end
