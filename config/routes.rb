Rails.application.routes.draw do
  get '/movies', to: 'movies#index', as: :movies_path
  root 'home#index'
end
