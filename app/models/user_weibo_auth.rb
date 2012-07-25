class UserWeiboAuth < ActiveRecord::Base
  belongs_to :user, :class_name => 'User', :foreign_key => 'user_id'


  # --- 给其他类扩展的方法
  module UserMethods
    def self.included(base)
      base.has_one :weibo_auth, :class_name => 'UserWeiboAuth', :foreign_key => :user_id

      base.send(:include, InstanceMethods)
    end
    
    module InstanceMethods
      def has_weibo_auth?
        UserWeiboAuth.where(:user_id => self.id).exists?
      end

      # begin set_new_weibo_auth
      def set_new_weibo_auth(auth_code, token, expires_in)
        # 如果过期重新设置的话，先删除，后面再创建新的
        self.weibo_auth.destroy unless self.weibo_auth.nil?

        unless has_weibo_auth?
          UserWeiboAuth.create(
            :user => self, :auth_code => auth_code, :token => token, :expires_in => expires_in
          )
        end
      end
      # end set_new_weibo_auth

    end
  end
  # end UserMethods

end
