class UserWeiboAuth < ActiveRecord::Base
  belongs_to :user, :class_name => 'User', :foreign_key => 'user_id'

  has_many :my_comments, 
           :class_name => 'WeiboComment',
           :conditions => lambda { "to_weibo_user_id != #{self.weibo_user_id}" },
           :foreign_key => :weibo_user_id, :primary_key => :weibo_user_id


  has_one :weibo_user, :class_name => 'WeiboUser', 
          :foreign_key => :weibo_user_id, :primary_key => :weibo_user_id



  def weibo_client
    Weibo2::Client.from_hash(:access_token => self.token, :expires_in => self.expires_in)
  end

  
  # 采集我发出的评论
  def get_my_comments_by_count(count)
    client = self.weibo_client

    current_page = 1
    if count <= 20
      response = client.comments.by_me(:page => current_page, :count => 20).parsed
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

  # 采集我收到的评论
  def get_received_comments_by_count(count)
    client = self.weibo_client

    current_page = 1
    if count <= 20
      response = client.comments.to_me(:page => current_page, :count => 20).parsed
      comments = response['comments']
    else
      comments = []
      while true do
        response = client.comments.to_me(:page => current_page, :count => 20).parsed
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


  def received_comments
    WeiboComment.where(:to_weibo_user_id => self.weibo_user_id)
  end


  def group_my_comments
    WeiboStatistics.group_data(self.my_comments)
  end

  def group_received_comments
    WeiboStatistics.group_data(self.received_comments)
  end



  # --- 给其他类扩展的方法
  module UserMethods
    def self.included(base)
      base.has_one :weibo_auth, :class_name => 'UserWeiboAuth', :foreign_key => :user_id

      base.send(:include, InstanceMethods)
    end
    
    module InstanceMethods
      def has_weibo_auth?
        !self.weibo_auth.blank?
      end

      # begin set_new_weibo_auth
      def set_new_weibo_auth(auth_code, client)
        # 如果过期重新设置的话，先删除，后面再创建新的
        if has_weibo_auth?
          self.weibo_auth.destroy
        end

        response = client.account.get_uid.parsed
        user = client.users.show(response).parsed

        UserWeiboAuth.create(
          :user => self, 
          :auth_code => auth_code, 
          :token => client.token.token, 
          :expires_in => client.token.expires_in,
          :weibo_user_id => response['uid'],
          :screen_name => user['screen_name'],
          :avatar => user['avatar_large']
        )
      end
      # end set_new_weibo_auth

      # begin get_weibo_client
      def get_weibo_client
        self.weibo_auth.weibo_client
      end
      # end get_weibo_client

    end
  end
  # end UserMethods

end
