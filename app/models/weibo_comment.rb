class WeiboComment < ActiveRecord::Base
  belongs_to :auth_user, 
             :class_name => 'UserWeiboAuth', 
             :foreign_key => :weibo_user_id, :primary_key => :weibo_user_id

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
      save_comments(comments)
    end

  end
  # end of update_by_weibo_status_id


  def self.get_my_comments_by_count(client_user, count)
    client = client_user.get_weibo_client

    current_page = 1
    if count <= 20
      response = client.comments.by_me(:page => current_page, :count => count).parsed
      comments = response['comments']
    else
      comments = []
      while true do
        response = client.comments.by_me(:page => current_page, :count => 20).parsed
        if comments.count + response['comments'].count < count
          comments = comments + response['comments']
          current_page += 1
        else
          index = count - comments.count
          comments += response['comments'][0...index]
          break
        end
      end
    end

    comments
  end
  # end of get_my_comments_by_count


  def self.save_comments(comments)
    unless comments.nil?
      comments.each do |comment|

        WeiboComment.create(
          :weibo_comment_id => comment['idstr'],
          :text => comment['text'],
          :weibo_user_id => comment['user']['idstr'],
          :weibo_status_id => comment['status']['idstr']
        )

        WeiboStatus.save_new(comment['status'])
      end
    end
  end
  # end of save_comments


end
