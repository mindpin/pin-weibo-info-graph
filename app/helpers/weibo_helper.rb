module WeiboHelper

  # 原创条数
  def get_origin_count(weibo_statuses)
    count = 0
    weibo_statuses.each do |weibo|
      if weibo.retweeted_status_id.nil?
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
      if weibo.retweeted_status_id.nil?
        unless weibo.thumbnail_pic.blank?
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
      unless weibo.retweeted_status_id.nil?
        
        retweeted_status = WeiboStatus.find_by_weibo_status_id(weibo.retweeted_status_id)
        unless !retweeted_status.nil? && retweeted_status.thumbnail_pic.blank?
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
      unless weibo.retweeted_status_id.nil?
        retweeted_status = WeiboStatus.find_by_weibo_status_id(weibo.retweeted_status_id)

        begin
          user = WeiboUser.find_by_weibo_user_id(retweeted_status.weibo_user_id)
          unless user.nil?
            users << user
          end
        rescue
          p weibo.retweeted_status_id
        end
      end
    end

    Hash[users.group_by {|x| x}.map {|k, v| [k, v.count]}]
  end
  # end get_forward_users

  def weibo_user_avatar(weibo_user)
    image_tag(weibo_user.profile_image_url)
  end

  def weibo_user_link(weibo_user)
    link_to weibo_user.screen_name, "/weibo_users/#{weibo_user.weibo_user_id}"
  end

end
