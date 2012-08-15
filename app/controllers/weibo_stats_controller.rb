class WeiboStatsController < ApplicationController
  # 统计分析：词汇使用趋势
  def stats1
    begin
      @group_words = current_user.weibo_auth.weibo_user.group_word_stats_of_statuses
    rescue
    end
  end


  # 按星期分组，统计我发出的评论与其它用户的互动
  def stats3
    begin
      # 当前登录用户发出的评论按星期分组
      @group_comments = current_user.weibo_auth.group_my_comments

      # 当前登录用户转发的微博按星期分组
      @group_retweeted = current_user.weibo_auth.weibo_user.group_retweeted_statuses

      # 当前登录用户转发的微博
      @retweeted_statuses = current_user.weibo_auth.weibo_user.retweeted_statuses
    rescue Exception=> ex
      p ex.message
      puts ex.backtrace*"\n"
      p 'weibo error'
    end
  end


  # 按星期分组，统计我收到的评论与其它用户的互动
  def stats11
    begin
      # 当前登录用户发出的评论按星期分组
      @group_comments = current_user.weibo_auth.group_received_comments

    rescue Exception=> ex
      p ex.message
      puts ex.backtrace*"\n"
      p 'weibo error'
    end
  end


  # 互相关注度
  def stats12
  end

  def stats12_submit
    @weibo_user_a = params[:weibo_user_a]
    @weibo_user_b = params[:weibo_user_b]

    if !@weibo_user_a.blank? && !@weibo_user_b.blank?
      @connection_friends = WeiboUser.get_connections(current_user, @weibo_user_a, @weibo_user_b)
    end

    render :action => 'stats12'
  end

  # 粉丝  关注用户列表
  def stats13
  end

  def stats13_submit
    client = current_user.weibo_auth.weibo_client
    screen_name = params[:screen_name]

    # 关注用户
    friends_data = []
    while true
      friends = client.friendships.friends(:screen_name => screen_name).parsed
      friends_data += friends['users']
      if friends['next_cursor'] >=0
        friends = client.friendships.friends(:screen_name => screen_name).parsed
        friends_data += friends['users']
      else
        break
      end
    end
    
    @friends_description_data = WeiboUser.new.combine_descriptions(friends_data)

    # 粉丝
    followers_data = []
    while true
      followers = client.friendships.followers(:screen_name => screen_name).parsed
      followers_data += followers['users']
      if followers['next_cursor'] >=0
        followers = client.friendships.followers(:screen_name => screen_name).parsed
        followers_data += followers['users']
      else
        break
      end
    end

    
    @followers_description_data = WeiboUser.new.combine_descriptions(followers_data)

    render :action => 'stats13'
  end


end
