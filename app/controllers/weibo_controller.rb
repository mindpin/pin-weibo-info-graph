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

  # 根据 weibo api 把数据采集到本地
  def grab
    unless params[:screen_name].blank?

      screen_name = params[:screen_name]
      count = params[:count].blank?? 0: params[:count].to_i

=begin
      # 先根据 api 获取微博列表
      weibo_statuses = WeiboStatus.get_weibo_statuses(current_user, screen_name, count)

      # 存到数据库
      WeiboStatus.store_weibo_statuses(weibo_statuses)
=end

      # 统计查询
      @weibo_user = WeiboUser.find_by_screen_name(screen_name)

      p @weibo_user.weibo_statuses
      p 888888888888888888888888

      render :nothing => true
    end
  end
  # end of grab


  # 微博数据统计
  def stats


=begin
    @client = current_user.get_weibo_client

    unless params[:screen_name].blank?
      screen_name = params[:screen_name]
      count = params[:count].blank?? 0: params[:count].to_i

      @user_weibo = @client.statuses.user_timeline({:screen_name => screen_name}).parsed
      @weibo_statuses = @user_weibo['statuses']

      # 如果用户输入的查询数量超过 20, 并且第一次查询结果也等于20, 说明用户的微博至少超过20
      if count > 20 && @weibo_statuses.length == 20
        api_count = count / 20

        api_count.times do |i|
          @user_weibo = @client.statuses.user_timeline({:screen_name => screen_name, :page => i + 1}).parsed
          
          # 数组查询合并
          @weibo_statuses =  @weibo_statuses + @user_weibo['statuses']
        end

        # 如果查询结果数量大于用户输入的数值， 则数组长度取用户输入的数值
        if @weibo_statuses.length > count
          count = count - 1
          @weibo_statuses = @weibo_statuses[0..count]
        end
        
      end

    end
=end
  end
  # end of stats





end
