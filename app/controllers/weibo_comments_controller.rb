class WeiboCommentsController < ApplicationController
  before_filter :per_load
  def per_load
    @weibo_status = WeiboStatus.find_by_weibo_status_id(params[:weibo_status_id]) if params[:weibo_status_id]
  end

  # 根据某条微博id, 显示相关的所有评论
  def index
    @weibo_user = @weibo_status.weibo_user
    @weibo_comments = @weibo_status.weibo_comments
  end

  # 重新更新某条微博对应的所有评论
  def refresh
    client = current_user.get_weibo_client
    @weibo_status.refresh_comments(client)

    redirect_to :back
  end

  # 当前登录用户发出的评论列表
  def by_me
    # 把我所有发出的评论从数据表拿出来显示在view上
    @my_comments = current_user.weibo_auth.my_comments
  end

  def refresh_by_me
    current_user.weibo_auth.refresh_my_comments
    redirect_to "/weibo_comments/by_me"
  end

  # 我收到的评论
  def to_me
    @received_comments = current_user.weibo_auth.received_comments
  end

  def refresh_to_me
    current_user.weibo_auth.refresh_received_comments
    redirect_to "/weibo_comments/to_me"
  end


end
