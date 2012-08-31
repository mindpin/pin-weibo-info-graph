class WeiboUsersController < ApplicationController
  def index
    @weibo_users = WeiboUser.paginate :page => params[:page],
                                      :per_page => 40
  end

  def word_stats
    @weibo_user = WeiboUser.find_by_weibo_user_id(params[:id])
    words = @weibo_user.word_stats.sort {|a1, a2| a2[1].to_i <=> a1[1].to_i }
    @top_20_words = words[0..19]
  end


  # 搜索微博用户
  def search
    keyword = URI.escape(params[:query])
    client = current_user.get_weibo_client
    response = client.search.suggestions_users(keyword).body

    users = ActiveSupport::JSON.decode response

    @users = []
    if !users.blank?
      users.each do |user|
        user_info = client.users.show(:uid => user['uid']).parsed
        WeiboUser.create_by_api_hash(user_info)

        @users << user_info
      end
    end
  end


  # 双向关注我的朋友
  def friends
    client = current_user.get_weibo_client
    @friends = current_user.weibo_auth.weibo_user.friends_bilateral(client)
  end

  def show
    @weibo_user = WeiboUser.find_by_weibo_user_id(params[:id])
    # @weibo_statuses = @weibo_user.weibo_statuses.paginate(:page => params[:page], :per_page => 20).order('id DESC')
    @weibo_statuses = @weibo_user.weibo_statuses.limit(200)
  end

  # 刷新微博用户最新微博
  def refresh_statuses
    client = current_user.get_weibo_client
    uid = params[:id]

    @weibo_user = WeiboUser.find_by_weibo_user_id(uid)
    @weibo_user.refresh_statuses(client)

    redirect_to "/weibo_users/#{uid}"
  end

  
  # 微博用户 和 我 的关系
  def connections
    weibo_user_a = current_user.weibo_auth.weibo_user.screen_name

    weibo_user = WeiboUser.find_by_weibo_user_id(params[:id])
    weibo_user_b = weibo_user.screen_name

    @connection_friends = WeiboUser.get_connections(current_user, weibo_user_a, weibo_user_b)
  end
end
