Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get "calendar_helper/week_starting"
      resources :accounts, only: %i[create show update destroy]
      resources :sessions, only: %i[index show create update destroy]
      resources :weather_entries, only: %i[index show], param: :date do
        collection do
          post :upsert
        end
      end
      resources :mood_entries, only: %i[index show], param: :date do
        collection do
          post :upsert
        end
      end
      resources :water_intake_entries, only: %i[index show], param: :date do
        collection do
          post :upsert
        end
      end
      resources :sleep_hours_entries, only: %i[index show], param: :date do
        collection do
          post :upsert
        end
      end
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
