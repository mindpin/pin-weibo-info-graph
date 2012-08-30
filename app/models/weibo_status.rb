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

    loop_to_request_weibo_api(count) do |current_page|
      response = client.comments.show(self.weibo_status_id,options.merge(:page => current_page, :count => 20)).parsed
      response['comments']
    end
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
