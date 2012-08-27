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

  def show
    @weibo_user = WeiboUser.find_by_weibo_user_id(params[:id])
    @weibo_statuses = @weibo_user.weibo_statuses.paginate(:page => params[:page], :per_page => 20).order('id DESC')
  end

  

  # 刷新微博用户最新微博
  def refresh
    uid = params[:id]
    since_id = WeiboStatus.find_all_by_weibo_user_id(uid).first.weibo_status_id

    client = current_user.get_weibo_client
    user_weibo = client.statuses.user_timeline(:uid => uid, :since_id => since_id).parsed

    WeiboStatus.store_weibo_statuses(user_weibo['statuses'])

    while true do
      since_id = WeiboStatus.find_all_by_weibo_user_id(uid).first.weibo_status_id
      user_weibo = client.statuses.user_timeline(:uid => uid, :since_id => since_id).parsed

      if user_weibo['statuses'].nil? || user_weibo['statuses'].count < 20
        return
      end
    end

    redirect_to "/weibo_users"

  end
end
