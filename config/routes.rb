Rails.application.routes.draw do
  post '/graphql', to: 'graphql#execute'

  if Rails.env.development?
    require 'graphiql/rails'
    mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: '/graphql'
    get '/downloads/:filename', to: 'downloads#show', as: :download
  end

  get 'up' => 'rails/health#show', as: :rails_health_check

  # Route for downloading generated CSV files
  get '/downloads/:filename', to: 'downloads#show', as: :download_file

  # root "posts#index"
end
