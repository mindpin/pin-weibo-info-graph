class WeiboUser < ActiveRecord::Base
  has_many :weibo_statuses, 
           :class_name => 'WeiboStatus', 
           :foreign_key => :weibo_user_id, :primary_key => :weibo_user_id

  #set_primary_key :weibo_user_id # 重新设置关联主键，不使用默认的 id 字段

  validates_uniqueness_of :weibo_user_id
end
