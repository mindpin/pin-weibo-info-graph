class WeiboStatsController < ApplicationController
  # 统计分析：词汇使用趋势
  def stats1
  end


  # 按星期分组，统计我发出的评论与其它用户的互动
  def stats3
    # 当前登录用户发出的评论按星期分组
    @group_comments = current_user.weibo_auth.group_comments

    # 当前登录用户转发的微博按星期分组
    @group_retweeted = current_user.weibo_auth.weibo_user.group_statuses

    # 当前登录用户转发的微博
    @retweeted_statuses = current_user.weibo_auth.weibo_user.retweeted_statuses

  end
  
end
