Rails.application.routes.draw do
  resources :prets do
    collection do 
      post 'nearest'
    end
  end
  resource :compass, :controller => "compass"

  root "compass#show"
end
