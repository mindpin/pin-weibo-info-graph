module WeiboHelper

  # 原创条数
  def get_origin_count(weibo_statuses)
    count = 0
    weibo_statuses.each do |weibo|
      if weibo['retweeted_status'].nil?
        count = count + 1
      end
    end

    count

  end
  #end origin_count

  
  # begin 原创微博中带有图片的微博
  def get_origin_count_with_pic(weibo_statuses)
    count = 0
    weibo_statuses.each do |weibo|
      if weibo['retweeted_status'].nil?
        unless weibo['thumbnail_pic'].blank?
          count = count + 1
        end
      end
    end

    count
  end
  # end get_origin_count_with_pic


  # begin 转发微博中带有图片的微博
  def get_forward_count_with_pic(weibo_statuses)
    count = 0
    weibo_statuses.each do |weibo|
      unless weibo['retweeted_status'].nil?
        unless weibo['retweeted_status']['thumbnail_pic'].blank?
          count = count + 1
        end
      end
    end

    count
  end
  # end get_forward_count_with_pic


  # begin 转发过以下这些人的微博
  def get_forward_users(weibo_statuses)
    users = []
    weibo_statuses.each do |weibo|
      unless weibo['retweeted_status'].nil?
        users << weibo['retweeted_status']['user']['screen_name']
      end
    end

    Hash[users.group_by {|x| x}.map {|k, v| [k, v.count]}]

  end
  # end get_forward_users

end
