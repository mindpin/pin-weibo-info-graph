class WeiboComment < ActiveRecord::Base
  belongs_to :weibo_status, 
             :class_name => 'WeiboStatus', 
             :foreign_key => :weibo_status_id
  
  validates_uniqueness_of :weibo_comment_id
end
