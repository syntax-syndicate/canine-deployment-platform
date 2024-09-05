# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  namespace :inbound_webhooks do
    resources :github, controller: :github, only: [:create]
  end
  resources :add_ons
  resources :projects do
    resources :metrics, only: [:index], module: :projects
    resources :project_add_ons, only: [:create, :destroy], module: :projects
    resources :environment_variables, only: [:index, :create], module: :projects
    resources :domains, only: [:create, :destroy], module: :projects
    resources :deployments, only: [:index, :show], module: :projects do
      collection do
        post :deploy
      end
      member do
        post :redeploy
      end
    end
    resource :shell, only: [:show, :create, :destroy], module: :projects do
      post :input, on: :collection
    end
  end
  resources :clusters do
    resource :metrics, only: [:show], module: :clusters
    member do
      post :test_connection
      post :restart
    end
  end
  draw :accounts
  draw :api
  draw :billing
  draw :turbo_native
  draw :users
  draw :dev if Rails.env.local?

  authenticated :user, lambda { |u| u.admin? } do
    draw :admin
  end

  resources :announcements, only: [:index, :show]

  namespace :action_text do
    resources :embeds, only: [:create], constraints: {id: /[^\/]+/} do
      collection do
        get :patterns
      end
    end
  end

  scope controller: :static do
    get :about
    get :terms
    get :privacy
    get :pricing
  end

  match "/404", via: :all, to: "errors#not_found"
  match "/500", via: :all, to: "errors#internal_server_error"

  authenticated :user do
    root to: "dashboard#show", as: :user_root
    # Alternate route to use if logged in users should still see public root
    # get "/dashboard", to: "dashboard#show", as: :user_root
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up", to: "rails/health#show", as: :rails_health_check

  # Public marketing homepage
  root to: "static#index"
end
