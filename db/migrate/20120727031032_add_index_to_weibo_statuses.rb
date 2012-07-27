class AddIndexToWeiboStatuses < ActiveRecord::Migration
  def change
    add_index :weibo_statuses, :weibo_status_id
    add_index :weibo_statuses, :weibo_user_id 
  end
end
