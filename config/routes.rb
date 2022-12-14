Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  # namespace :api, defaults: { format: :json } do
  #   namespace :v1 do
  #     resources :transactions, only: %i[create]
  #   end
  # end

  require 'sidekiq/web'

  mount Sidekiq::Web => '/sidekiq'

  resources :transactions, only: %i[create], defaults: { format: :json }
end
