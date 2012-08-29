class WeiboStatus < ActiveRecord::Base
  belongs_to :retweeted_status, :class_name => 'WeiboStatus', 
             :foreign_key => :retweeted_status_id, 
             :primary_key => :weibo_status_id

  belongs_to :weibo_user, 
             :class_name => 'WeiboUser', 
             :foreign_key => :weibo_user_id, :primary_key => :weibo_user_id

  has_many :weibo_comments, :class_name => 'WeiboComment', :foreign_key => :weibo_status_id


  # 验证
  validates_uniqueness_of :weibo_status_id


  # scope
  default_scope order('weibo_status_id DESC')
  scope :of_weibo_user_id, lambda{|weibo_user_id|where(:weibo_user_id => weibo_user_id)}

  
  # 刷新微博对应的评论
  def refresh_comments(user)
    client = user.get_weibo_client
    response = client.comments.show(self.weibo_status_id).parsed
    comments = response['comments']

    unless comments.nil?
      WeiboComment.destroy_all(:weibo_status_id => self.weibo_status_id)
      WeiboComment.save_comments(comments)
    end
  end

  def self.get_weibo_statuses(user, screen_name, count)
    self._get_weibo_statuses(user, count, :screen_name => screen_name)
  end

  def self.refresh(user,uid)
    params = {}
    newest_status = WeiboStatus.of_weibo_user_id(uid).first
    if !newest_status.blank?
      params[:since_id] = newest_status.weibo_status_id
    end
    weibo_statuses = self._get_weibo_statuses(user, 200, params)
    p "~~~~~~~~~~~~~~~~"
    p weibo_statuses
    WeiboStatus.store_weibo_statuses(weibo_statuses)
  end

  # 先根据 api 获取微博列表
  def self._get_weibo_statuses(user, count, options = {})
    client = user.get_weibo_client

    if count <= 20
      user_weibo = client.statuses.user_timeline(options.merge(:page => 1, :count => 20)).parsed
      return user_weibo['statuses']
    end

    weibo_statuses = []
    current_page = 1
    while true do
      user_weibo = client.statuses.user_timeline(options.merge(:page => current_page, :count => 20)).parsed
      single_weibo_statuses = user_weibo['statuses']
      break if single_weibo_statuses.nil?

      if weibo_statuses.count + single_weibo_statuses.count < count
        weibo_statuses += single_weibo_statuses
        current_page += 1
      else
        index = count - weibo_statuses.count
        weibo_statuses += single_weibo_statuses[0...index]
        break
      end
    end
    weibo_statuses
  end
  # end get_weibo_statuses

  
  # 采集存到数据表
  def self.store_weibo_statuses(weibo_statuses)
    
    unless weibo_statuses.nil?
      weibo_statuses.each do |weibo|
        save_new(weibo)
      end

    end
    
  end
  # end of store_weibo_statuses


  def self.save_new(weibo)
    if weibo.blank?
      return
    end
    
    retweeted_status = weibo['retweeted_status'].nil?? '': weibo['retweeted_status']
    weibo_user_id = weibo['user'].nil?? '': weibo['user']['id']
    weibo_created_at = Date.parse(weibo['created_at']) unless weibo['created_at'].blank?


    # 创建 WeiboStatus 记录
    WeiboStatus.create(
      :weibo_status_id => weibo['id'],
      :weibo_user_id => weibo_user_id,
      :text => weibo['text'],
      :retweeted_status_id => retweeted_status['id'],
      :bmiddle_pic => weibo['bmiddle_pic'],
      :original_pic => weibo['original_pic'],
      :thumbnail_pic => weibo['thumbnail_pic'],
      :weibo_created_at => weibo_created_at,
      :json => weibo.to_json
    )

    # 根据 retweeted_status 再创新新的 WeiboStatus 记录
    create_retweeted_status(retweeted_status)

    # 创建微博用户
    create_weibo_user(weibo)
  end
  # end of save_new

  
  # begin 根据 retweeted_status 字段 创建新的 WeiboStatus
  def self.create_retweeted_status(retweeted_status)
    if retweeted_status.blank?
      return
    end

    weibo_user_id = retweeted_status['user'].nil?? '': retweeted_status['user']['id']

    weibo_created_at = Date.parse(retweeted_status['created_at']) unless retweeted_status['created_at'].blank?

    WeiboStatus.create(
      :weibo_status_id => retweeted_status['idstr'],
      :weibo_user_id => weibo_user_id,
      :text => retweeted_status['text'],
      :retweeted_status_id => '',
      :bmiddle_pic => retweeted_status['bmiddle_pic'],
      :original_pic => retweeted_status['original_pic'],
      :thumbnail_pic => retweeted_status['thumbnail_pic'],
      :weibo_created_at => weibo_created_at,
      :json => retweeted_status.to_json
    )

    # 创建微博用户
    create_weibo_user(retweeted_status)
  end
  # end of create_retweeted_status


  def self.create_weibo_user(weibo)
    unless weibo['user'].nil?
      WeiboUser.create(
        :weibo_user_id => weibo['user']['id'],
        :screen_name => weibo['user']['screen_name'],
        :profile_image_url => weibo['user']['profile_image_url'],
        :gender  => weibo['user']['gender'],
        :description => weibo['user']['description'],
        :json => weibo['user'].to_json
      )
    else
      p weibo
    end

  end
  # end create_weibo_user



end
