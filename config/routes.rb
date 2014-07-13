Rails.application.routes.draw do
  resources :users do
    post 'identify', :on => :collection
    get 'home'
  end

  root 'd2d_sync#index'

  get 'home' => 'home#index'
  get 'home/sync' => 'home#sync'
  get 'identify/dropbox' => 'world_identity#dropbox'
  get 'identify/google' => 'world_identity#google'
  get 'revoke/google' => 'world_identity#revoke_google'
  get 'revoke/dropbox' => 'world_identity#revoke_dropbox'
  get 'logout' => 'home#logout'
  
end
