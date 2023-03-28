Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"


	namespace :api do
		namespace :v1	do
			get '/merchants/find_all', to: "merchant/search#index"
			resources :merchants, only: [:index, :show] do
				resources :items, only: [:index], controller: 'merchant/items'
			end
			resources :items do
				resource :merchant, only: [:show], controller: 'merchants'
			end
		end
	end
end
