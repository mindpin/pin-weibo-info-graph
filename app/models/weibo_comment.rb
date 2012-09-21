class WeiboComment < ActiveRecord::Base
  belongs_to :auth_user, 
             :class_name => 'UserWeiboAuth', 
             :foreign_key => :weibo_user_id, :primary_key => :weibo_user_id

  belongs_to :weibo_status, 
             :class_name => 'WeiboStatus', 
             :foreign_key => :weibo_status_id, :primary_key => :weibo_status_id
  
  validates :weibo_comment_id, :uniqueness => true

  validates :weibo_comment_id, 
            :text, :weibo_user_id, 
            :weibo_status_id, :weibo_created_at, :json, :to_weibo_user_id,  :presence => true

  default_scope order('weibo_comment_id DESC')

  def self.create_by_api_hash(comment)
    return if comment.blank?
    return if !WeiboComment.find_by_weibo_comment_id(comment['idstr']).blank?

    weibo_created_at = Date.parse(comment['created_at']) unless comment['created_at'].blank?

    WeiboComment.create(
      :weibo_comment_id => comment['idstr'],
      :text => comment['text'],
      :weibo_user_id => comment['user']['idstr'],
      :weibo_status_id => comment['status']['idstr'],
      :weibo_created_at => weibo_created_at,
      :json => comment.to_json,
      :to_weibo_user_id => comment['status']['user']['id']
    )

    WeiboStatus.create_by_api_hash(comment['status'])
    WeiboUser.create_by_api_hash(comment['user'])
  end

end
