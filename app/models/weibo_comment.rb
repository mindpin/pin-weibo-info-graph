class WeiboComment < ActiveRecord::Base
  belongs_to :auth_user, 
             :class_name => 'UserWeiboAuth', 
             :foreign_key => :weibo_user_id, :primary_key => :weibo_user_id

  belongs_to :weibo_status, 
             :class_name => 'WeiboStatus', 
             :foreign_key => :weibo_status_id, :primary_key => :weibo_status_id
  
  validates_uniqueness_of :weibo_comment_id



  def self.save_comments(comments)
    unless comments.nil?
      comments.each do |comment|

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

        WeiboStatus.save_new(comment['status'])

        # 创建微博用户
        WeiboStatus.create_weibo_user(comment)
      end
    end
  end
  # end of save_comments


end
