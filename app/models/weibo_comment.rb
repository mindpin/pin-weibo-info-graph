class WeiboComment < ActiveRecord::Base
  belongs_to :weibo_status, 
             :class_name => 'WeiboStatus', 
             :foreign_key => :weibo_status_id, :primary_key => :weibo_status_id
  
  validates_uniqueness_of :weibo_comment_id


  def self.update_by_weibo_status_id(client_user, weibo_status_id)
    if weibo_status_id.nil?
      return
    end

    client = client_user.get_weibo_client
    response = client.comments.show(weibo_status_id).parsed
    comments = response['comments']

    unless comments.nil?
      WeiboComment.destroy_all(:weibo_status_id => weibo_status_id)
      comments.each do |comment|
        WeiboComment.create(
          :weibo_comment_id => comment['idstr'],
          :text => comment['text'],
          :weibo_user_id => comment['user']['idstr'],
          :weibo_status_id => comment['status']['idstr']
        )
      end
    end

  end
  # end of update_by_weibo_status_id

end
