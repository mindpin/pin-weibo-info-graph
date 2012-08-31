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
      
    end
  end

  resources :weibo_users do
    member do
      get :word_stats
      get :refresh_statuses
      get :relation
    end

    collection do
      get :search
      get :friends
    end
  end
  # end of weibo users

  # begin of weibo comments
  resources :weibo_comments,:except => [:index] do
    collection do
      # 我发出的评论
      get :by_me
      post :refresh_by_me

      # 我收到的评论
      get :to_me
      post :refresh_to_me
    end
  end

  scope 'weibo_statuses/:weibo_status_id' do
    resources :weibo_comments do
      collection do
        post :refresh
      end
    end
  end
  # end of weibo comments



  # begin of stats
  resources :weibo_stats do
    collection do
      # 统计分析：词汇使用趋势
      get :stats1

      # 统计分析: 评论转发趋势
      get :stats3

      # 统计分析：被评论趋势
      get :stats11

      # 粉丝 微博用户关注的用户
      get :stats13
      post :stats13_submit
    end
  end
  # end of stats


end
