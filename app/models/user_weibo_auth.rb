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

      def set_new_weibo_auth(auth_code)
        unless has_weibo_auth?
          UserWeiboAuth.create(:user => self, :auth_code => auth_code)
        end
      end
    end
  end
  # end UserMethods

end
