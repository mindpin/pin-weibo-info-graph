class UserWeiboAuth < ActiveRecord::Base
  belongs_to :user, :class_name => 'User', :foreign_key => 'user_id'

  has_many :weibo_comments, 
           :class_name => 'WeiboComment', 
           :foreign_key => :weibo_user_id, :primary_key => :weibo_user_id


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

        UserWeiboAuth.create(
          :user => self, 
          :auth_code => auth_code, 
          :token => client.token.token, 
          :expires_in => client.token.expires_in,
          :uid => response['uid']
        )
      end
      # end set_new_weibo_auth

      # begin get_weibo_client
      def get_weibo_client
        token = self.weibo_auth.token
        expires_in = self.weibo_auth.expires_in

        Weibo2::Client.from_hash(:access_token => token, :expires_in => expires_in)
      end
      # end get_weibo_client

    end
  end
  # end UserMethods

end
