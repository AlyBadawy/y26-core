Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :accounts, only: %i[create show update destroy]
      resources :sessions, only: %i[index show create update destroy]
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
