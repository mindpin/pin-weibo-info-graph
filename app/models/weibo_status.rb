class WeiboStatus < ActiveRecord::Base
  #belongs_to :retweeted_status, :class_name => 'WeiboStatus', :foreign_key => :retweeted_status_id

  belongs_to :weibo_user, 
             :class_name => 'WeiboUser', 
             :foreign_key => :weibo_user_id, :primary_key => :weibo_status_id

  # has_many :weibo_statuses, :class_name => 'WeiboStatus', :foreign_key => :retweeted_status_id

  #set_primary_key :weibo_status_id # 重新设置关联主键，不使用默认的 id 字段
  
  validates_uniqueness_of :weibo_status_id


  # 先根据 api 获取微博列表
  def self.get_weibo_statuses(user, screen_name, count)
    client = user.get_weibo_client

    user_weibo = client.statuses.user_timeline({:screen_name => screen_name}).parsed
    weibo_statuses = user_weibo['statuses']

    # 如果用户输入的查询数量超过 20, 并且第一次查询结果也等于20, 说明用户的微博至少超过20
    if count > 20 && weibo_statuses.length == 20
      api_count = count / 20

      api_count.times do |i|
        user_weibo = client.statuses.user_timeline({:screen_name => screen_name, :page => i + 1}).parsed
        
        # 数组查询合并
        weibo_statuses =  weibo_statuses + user_weibo['statuses']
      end

      # 如果查询结果数量大于用户输入的数值， 则数组长度取用户输入的数值
      if weibo_statuses.length > count
        count = count - 1
        weibo_statuses = weibo_statuses[0..count]
      end
    end

    weibo_statuses

  end
  # end get_weibo_statuses

  
  # 采集存到数据表
  def self.store_weibo_statuses(weibo_statuses)
    
    unless weibo_statuses.nil?
      weibo_statuses.each do |weibo|

        retweeted_status = weibo['retweeted_status'].nil?? '': weibo['retweeted_status']

        # 创建 WeiboStatus 记录
        WeiboStatus.create(
          :weibo_status_id => weibo['id'],
          :weibo_user_id => weibo['user']['id'],
          :text => weibo['text'],
          :retweeted_status_id => retweeted_status['id'],
          :bmiddle_pic => weibo['bmiddle_pic'],
          :original_pic => weibo['original_pic'],
          :thumbnail_pic => weibo['thumbnail_pic'],
          :json => weibo.to_json
        )

        # 根据 retweeted_status 再创新新的 WeiboStatus 记录
        create_retweeted_status(retweeted_status)

        # 创建微博用户
        create_weibo_user(weibo)
      end

    end
    
  end
  # end of store_weibo_statuses

  
  # begin 根据 retweeted_status 字段 创建新的 WeiboStatus
  def self.create_retweeted_status(retweeted_status)
    if retweeted_status.blank?
      return
    end

    weibo_user_id = retweeted_status['user'].nil?? '': retweeted_status['user']['id']

    WeiboStatus.create(
      :weibo_status_id => retweeted_status['idstr'],
      :weibo_user_id => weibo_user_id,
      :text => retweeted_status['text'],
      :retweeted_status_id => '',
      :bmiddle_pic => retweeted_status['bmiddle_pic'],
      :original_pic => retweeted_status['original_pic'],
      :thumbnail_pic => retweeted_status['thumbnail_pic'],
      :json => retweeted_status.to_json
    )

    # 创建微博用户
    create_weibo_user(retweeted_status)
  end
  # end of create_retweeted_status


  def self.create_weibo_user(weibo)
    WeiboUser.create(
      :weibo_user_id => weibo['user']['id'],
      :screen_name => weibo['user']['screen_name'],
      :profile_image_url => weibo['user']['profile_image_url'],
      :gender  => weibo['user']['gender'],
      :description => weibo['user']['description'],
      :json => weibo['user'].to_json
    )
  end
  # end create_weibo_user

end
