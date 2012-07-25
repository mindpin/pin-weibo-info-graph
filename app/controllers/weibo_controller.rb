class WeiboController < ApplicationController
  before_filter :login_required

  def index
    @new_client = Weibo2::Client.new

    unless current_user.weibo_auth.nil?
      code = current_user.weibo_auth.auth_code
      client = Weibo2::Client.from_code(code)
      if client.is_authorized?
        response = client.account.get_uid
        # @weibo_user = client.users.show(response.parsed)
      end
    end

  end

  def callback
    code = params[:code]
    client = Weibo2::Client.from_code(code)

    if client.is_authorized?
      current_user.set_new_weibo_auth(code)
    end

    redirect_to "/weibo"
  end
end
