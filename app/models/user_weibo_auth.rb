class UserWeiboAuth < ActiveRecord::Base
  belongs_to :user, :class_name => 'User', :foreign_key => 'user_id'

  has_many :my_comments, 
           :class_name => 'WeiboComment',
           :conditions => lambda { "to_weibo_user_id != #{self.weibo_user_id}" },
           :order => 'weibo_comment_id desc',
           :foreign_key => :weibo_user_id, :primary_key => :weibo_user_id

  has_many :received_comments,
           :class_name => 'WeiboComment',
           :order => 'weibo_comment_id desc',
           :foreign_key => :to_weibo_user_id, :primary_key => :weibo_user_id

  has_one :weibo_user, :class_name => 'WeiboUser', 
          :foreign_key => :weibo_user_id, :primary_key => :weibo_user_id



  def weibo_client
    Weibo2::Client.from_hash(:access_token => self.token, :expires_in => self.expires_in)
  end

  def refresh_my_comments
    options = {}
    comment = self.my_comments.first
    if !comment.blank?
      options[:since_id] = comment.weibo_comment_id
    end
    comments = get_my_comments_by_count(200,options)
    comments.each{|comment|WeiboComment.create_by_api_hash(comment)}
  end

  def refresh_received_comments
    options = {}
    comment = self.received_comments.first
    if !comment.blank?
      options[:since_id] = comment.weibo_comment_id
    end
    comments = get_received_comments_by_count(200,options)
    comments.each{|comment|WeiboComment.create_by_api_hash(comment)}
  end
  
  # 采集我发出的评论
  def get_my_comments_by_count(count,options)
    client = self.weibo_client

    loop_to_request_weibo_api(count) do |current_page|
      response = client.comments.by_me(options.merge(:page => current_page, :count => 20)).parsed
      response['comments']
    end
  end

  # 采集我收到的评论
  def get_received_comments_by_count(count,options)
    client = self.weibo_client

    loop_to_request_weibo_api(count) do |current_page|
      response = client.comments.to_me(options.merge(:page => current_page, :count => 20)).parsed
      response['comments']
    end
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
        (!self.weibo_auth.blank?) && (
          client = self.get_weibo_client
          uid = self.weibo_auth.weibo_user_id
          !client.users.show(:uid => uid).parsed.blank?
        )
      rescue
        false
      end

      # begin set_new_weibo_auth
      def set_new_weibo_auth(auth_code, client)
        # 如果过期重新设置的话，先删除，后面再创建新的
        self.weibo_auth.destroy if !self.weibo_auth.blank?

        response = client.account.get_uid.parsed
        # user = client.users.show(response).parsed
        user = WeiboApiCache.show(client, response)

        UserWeiboAuth.create(
          :user => self, 
          :auth_code => auth_code, 
          :token => client.token.token, 
          :expires_in => client.token.expires_in,
          :weibo_user_id => response['uid'],
          :screen_name => user.screen_name,
          :avatar => user.profile_image_url
        )
        WeiboUser.create_by_api_hash(user)
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
