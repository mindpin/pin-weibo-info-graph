class WeiboController < ApplicationController
  before_filter :login_required

  def index
    @new_client = Weibo2::Client.new

    unless current_user.weibo_auth.nil?
      @client = current_user.get_weibo_client
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
    client = current_user.get_weibo_client
    client.statuses.update(params[:content])

    redirect_to :back
  end


  # 微博数据统计
  def stats
    @client = current_user.get_weibo_client

    unless params[:screen_name].blank?
      @weibo_statuses = []
      screen_name = params[:screen_name]
      count = params[:count].blank?? 0: params[:count].to_i

      @user_weibo = @client.statuses.user_timeline({:screen_name => screen_name}).parsed
      @weibo_statuses = @weibo_statuses + @user_weibo['statuses']

      if count > 20
        api_count = count / 20
        
        api_count.times do |i|
          @next_user_weibo = @client.statuses.user_timeline({:screen_name => screen_name, :page => i + 1}).parsed

          @weibo_statuses =  @weibo_statuses + @user_weibo['statuses']
        end
      end

    end


  end




end
