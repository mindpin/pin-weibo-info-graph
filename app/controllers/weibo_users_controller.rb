class WeiboUsersController < ApplicationController
  before_filter :login_required
  before_filter :pre_load

  def pre_load
    @weibo_user = WeiboUser.find_by_weibo_user_id(params[:id]) if params[:id]
  end

  def index
    @weibo_users = WeiboUser.paginate :page => params[:page],
                                      :per_page => 40
  end

  def word_stats
    words = @weibo_user.word_stats.sort {|a1, a2| a2[1].to_i <=> a1[1].to_i }
    @top_20_words = words[0..19]
  end


  # 搜索微博用户
  def search
    client = current_user.get_weibo_client
    @weibo_users = WeiboUser.search(client,params[:query])
  end

  # 双向关注我的朋友
  def friends
    client = current_user.get_weibo_client
    @weibo_users = current_user.weibo_auth.weibo_user.friends_bilateral(client)
  end

  def show
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
  def relation
    client = current_user.get_weibo_client
    @relations = current_user.weibo_auth.weibo_user.relation(client,@weibo_user)
  end

  # 查看好友特征
  def feature
    weibo_client = current_user.weibo_auth.weibo_client

    # 我关注的人
    # friends = @weibo_user.get_friends(weibo_client)
    friends = WeiboApiCache.friends(weibo_client, @weibo_user) 
    @friends_description_data = WeiboUser.new.combine_descriptions(friends)


    # 关注我的人
    @followers = @weibo_user.get_followers(weibo_client)
    # @followers_description_data = WeiboUser.new.combine_descriptions(followers)
  end
end
