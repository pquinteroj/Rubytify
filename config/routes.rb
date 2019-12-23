Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  #test api
  get '/health', to: 'health#health'


  namespace 'api' do
    namespace 'v1' do
       get '/artists', to: 'artists#index'
       get '/artists/:id/albums', to: 'artists#albums'
       get '/albums/:id/songs', to: 'albums#songs'
       get '/genres/:genre_name/random_song', to: 'genres#index'
    end
  end

end
