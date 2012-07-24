class IndexController < ApplicationController
  def index
    if logged_in?
      return render :template=>'index/index'
    end
    
    # 如果还没有登录，渲染登录页
    return render :template=>'index/login'


  end

  def callback
    client = Weibo2::Client.from_hash(:access_token => params[:code])
    
    if client.is_authorized?
      response = client.account.get_uid
    end

    render :nothing => true
  end

end
