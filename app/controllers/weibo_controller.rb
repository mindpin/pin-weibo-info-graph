class WeiboController < ApplicationController
  before_filter :login_required

  def index
    if !current_user.has_weibo_auth?
      return render :template => 'weibo/no_weibo_auth'
    end

  end

  def callback
    code = params[:code]
    client = Weibo2::Client.from_code(code)

    if client.is_authorized?
      current_user.set_new_weibo_auth(code, client)
    end

    redirect_to "/weibo"
  end

  # 发送微博
  def create
    client = current_user.get_weibo_client
    client.statuses.update(params[:content])

    redirect_to :back
  end

  

end
