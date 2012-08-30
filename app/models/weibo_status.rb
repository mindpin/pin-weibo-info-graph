class WeiboStatus < ActiveRecord::Base
  belongs_to :retweeted_status, :class_name => 'WeiboStatus', 
             :foreign_key => :retweeted_status_id, 
             :primary_key => :weibo_status_id

  belongs_to :weibo_user, 
             :class_name => 'WeiboUser', 
             :foreign_key => :weibo_user_id, :primary_key => :weibo_user_id

  has_many :weibo_comments, :class_name => 'WeiboComment', :foreign_key => :weibo_status_id,
    :primary_key => :weibo_status_id, :order => 'weibo_comments.weibo_comment_id desc'


  # 验证
  validates :weibo_status_id, :uniqueness=> true


  # scope
  default_scope order('weibo_status_id DESC')
  scope :of_weibo_user_id, lambda{|weibo_user_id|where(:weibo_user_id => weibo_user_id)}

  
  # 刷新微博对应的评论
  def refresh_comments(client)
    comments = get_comments(client,200)
    comments.each{|comment| WeiboComment.create_by_api_hash(comment)}
  end

  def get_comments(client,count)
    options = {}
    comment = self.weibo_comments.first
    options[:since_id] = comment.weibo_comment_id if !comment.blank?

    current_page = 1
    all_comments = []
    while true do
      response = client.comments.show(self.weibo_status_id,options.merge(:page => current_page, :count => 20)).parsed
      comments = response['comments']
      break if comments.blank?

      if all_comments.count + comments.count < count
        all_comments+=comments
        current_page+=1
      else
        index = count - all_comments.count
        all_comments += comments[0...index]
        break
      end
    end

    all_comments
  end

  def self.get_weibo_statuses(user, screen_name, count)
    client = user.get_weibo_client
    self._get_weibo_statuses(client, count, :screen_name => screen_name)
  end

  def self.refresh(client,uid)
    params = {:uid => uid}
    newest_status = WeiboStatus.of_weibo_user_id(uid).first
    if !newest_status.blank?
      params[:since_id] = newest_status.weibo_status_id
    end
    weibo_statuses = self._get_weibo_statuses(client, 200, params)
    weibo_statuses.each{|status|WeiboStatus.create_by_api_hash(status)}
  end

  # 先根据 api 获取微博列表
  def self._get_weibo_statuses(client, count, options = {})
    if count <= 20
      user_weibo = client.statuses.user_timeline(options.merge(:page => 1, :count => 20)).parsed
      return user_weibo['statuses']
    end

    weibo_statuses = []
    current_page = 1
    while true do
      user_weibo = client.statuses.user_timeline(options.merge(:page => current_page, :count => 20)).parsed
      single_weibo_statuses = user_weibo['statuses']
      break if single_weibo_statuses.blank?

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

  def self.create_by_api_hash(status)
    return if status.blank?
    return if !WeiboStatus.find_by_weibo_status_id(status['id']).blank?
    
    retweeted_status = status['retweeted_status']
    retweeted_status_id = retweeted_status.blank? ? '' : retweeted_status['id']

    weibo_user_id = status['user'].blank? ? '' : status['user']['id']
    weibo_created_at = Date.parse(status['created_at']) unless status['created_at'].blank?

    # 创建 WeiboStatus 记录
    WeiboStatus.create(
      :weibo_status_id => status['id'],
      :weibo_user_id => weibo_user_id,
      :text => status['text'],
      :retweeted_status_id => retweeted_status_id,
      :bmiddle_pic => status['bmiddle_pic'],
      :original_pic => status['original_pic'],
      :thumbnail_pic => status['thumbnail_pic'],
      :weibo_created_at => weibo_created_at,
      :json => status.to_json
    )

    # 根据 retweeted_status 再创新新的 WeiboStatus 记录
    WeiboStatus.create_by_api_hash(retweeted_status) if !retweeted_status.blank?

    # 创建微博用户
    WeiboUser.create_by_api_hash(status['user'])
  end
  
end
