class UserWeiboAuth < ActiveRecord::Base
  belongs_to :user, :class_name => 'User', :foreign_key => 'user_id'

  has_many :weibo_comments, 
           :class_name => 'WeiboComment', :order => 'created_at',
           :foreign_key => :weibo_user_id, :primary_key => :weibo_user_id



  def group_comments_by_week
    comments = self.weibo_comments

    start_date = comments[0].created_at.strftime('%Y-%m-%d')
    end_date = comments[comments.length - 1].created_at.strftime('%Y-%m-%d')
    start_week_day = comments[0].created_at.wday
    end_week_day = comments[comments.length - 1].created_at.wday

    #p start_date
    #p end_date

    total_days = (Date.parse(end_date) - Date.parse(start_date)).round

    #p total_days
    
    week_comments = []
    first_week_days = 7 - start_week_day
    if first_week_days > total_days
      week_comments << comments
    else
      temp_comments = []
      end_week_date = Date.parse(comments[0].created_at.to_s) + first_week_days
      comments.each do |comment|
        if comment.created_at <= end_week_date
          temp_comments << comment
        end
      end

      week_comments << temp_comments
      week_comments = self.divide_week_comments(total_days, week_comments, comments)
    end

    week_comments
  end

  def divide_week_comments(total_days, week_comments, comments)
    last_week_comments = week_comments[week_comments.length - 1]
    end_week_date = Date.parse(last_week_comments[last_week_comments.length - 1].created_at.to_s) + 7
    end_date = Date.parse(comments[comments.length - 1].created_at.to_s)


    temp_comments = []
    last_week_date = Date.parse(last_week_comments[last_week_comments.length - 1].created_at.to_s)


    if end_week_date < end_date
      
      comments.each do |comment|
        current_date = Date.parse(comment.created_at.to_s)
        if current_date > last_week_date && current_date <= end_week_date
          temp_comments << comment
        end
      end
      week_comments << temp_comments
      self.divide_week_comments(total_days, week_comments, comments)
    else
      end_week_date = last_week_date + 6
      comments.each do |comment|
        current_date = Date.parse(comment.created_at.to_s)
        if current_date > last_week_date && current_date <= end_week_date
          temp_comments << comment
        end
      end
      week_comments << temp_comments
      return week_comments
      
    end
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

        UserWeiboAuth.create(
          :user => self, 
          :auth_code => auth_code, 
          :token => client.token.token, 
          :expires_in => client.token.expires_in,
          :weibo_user_id => response['uid']
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
