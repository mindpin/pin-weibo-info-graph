PinWorkResultsShow::Application.routes.draw do
  # -- 用户登录认证相关 --
  root :to=>"index#index"
  get  '/login'  => 'sessions#new'
  post '/login'  => 'sessions#create'
  get  '/logout' => 'sessions#destroy'
  
  get  '/signup'        => 'signup#form'
  post '/signup_submit' => 'signup#form_submit'


  resources :weibo do
    collection do
      get :callback
      get :stats
    end
  end

  # begin of weibo users
  get '/weibo_users/:weibo_user_id/word_stats'          => 'weibo_users#word_stats'
  # end of weibo users

  
  # begin of weibo comments
  resources :weibo_comments do
    collection do
    end
  end
  # end of weibo comments

end
