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
    # @weibo_statuses = @weibo_user.weibo_statuses.paginate(:page => params[:page], :per_page => 20).order('id DESC')
    @weibo_statuses = @weibo_user.weibo_statuses.order('id DESC').all(:limit => 200)
  end

  # 刷新微博用户最新微博
  def refresh
    client = current_user.get_weibo_client
    uid = params[:id]

    WeiboStatus.refresh(current_user,uid)

    redirect_to "/weibo_users/#{uid}"
  end
end
