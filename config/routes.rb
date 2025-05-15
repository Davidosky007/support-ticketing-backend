Rails.application.routes.draw do
  post '/graphql', to: 'graphql#execute'

  if Rails.env.development?
    require 'graphiql/rails'
    mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: '/graphql'
  end

  get 'up' => 'rails/health#show', as: :rails_health_check

  # Route for downloading generated CSV files - works in all environments
  get '/downloads/:filename', to: 'downloads#show', as: :download_file

  # Route for manually triggering daily emails
  post '/send_daily_emails', to: 'downloads#send_daily_emails'

  # root "posts#index"
end
