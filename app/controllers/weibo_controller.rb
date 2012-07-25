class WeiboController < ApplicationController
  before_filter :login_required

  def index
    @new_client = Weibo2::Client.new

    unless current_user.weibo_auth.nil?
      token = current_user.weibo_auth.token
      expires_in = current_user.weibo_auth.expires_in

      @client = Weibo2::Client.from_hash(:access_token => token, :expires_in => expires_in)
      if @client.is_authorized?
        response = @client.account.get_uid
        @weibo_user = @client.users.show(response.parsed).parsed
      end
    end

  end

  def callback
    code = params[:code]
    client = Weibo2::Client.from_code(code)

    if client.is_authorized?
      current_user.set_new_weibo_auth(code, client.token.token, client.token.expires_in)
    end

    redirect_to "/weibo"
  end

  # 发送微博
  def create
    token = current_user.weibo_auth.token
    expires_in = current_user.weibo_auth.expires_in

    client = Weibo2::Client.from_hash(:access_token => token, :expires_in => expires_in)

    client.statuses.update(params[:content])

    redirect_to :back
  end
end
