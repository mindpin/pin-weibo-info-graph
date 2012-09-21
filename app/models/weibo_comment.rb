class WeiboComment < ActiveRecord::Base
  belongs_to :weibo_user, 
             :class_name => 'WeiboUser', 
             :foreign_key => :weibo_user_id, 
             :primary_key => :weibo_user_id

  belongs_to :to_weibo_user,
             :class_name => 'WeiboUser', 
             :foreign_key => :to_weibo_user_id, 
             :primary_key => :weibo_user_id

  belongs_to :weibo_status, 
             :class_name => 'WeiboStatus', 
             :foreign_key => :weibo_status_id, :primary_key => :weibo_status_id
  
  validates :weibo_comment_id, :uniqueness => true

  validates :weibo_comment_id, 
            :text, 
            :weibo_user_id, 
            :weibo_status_id, 
            :data_created_at, 
            :json, 
            :to_weibo_user_id,
            :presence => true

  default_scope order('weibo_comment_id DESC')

  def self.create_by_api_hash(comment)
    return if comment.blank?
    return if !WeiboComment.find_by_weibo_comment_id(comment['idstr']).blank?

    WeiboComment.create(
      :weibo_comment_id => comment['idstr'],                  # 评论ID
      :text             => comment['text'],                   # 评论正文
      :weibo_user_id    => comment['user']['idstr'],          # 评论作者ID
      :weibo_status_id  => comment['status']['idstr'],        # 评论所在的微博ID
      :data_created_at  => Date.parse(comment['created_at']), # 评论的发布日期
      :json             => comment.to_json,                   # 评论的原始json
      :to_weibo_user_id => comment['status']['user']['id']    # 评论针对的用户ID
    )

    WeiboStatus.create_by_api_hash(comment['status'])
    WeiboUser.create_by_api_hash(comment['user'])
  end

end
