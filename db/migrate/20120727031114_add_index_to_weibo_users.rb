class AddIndexToWeiboUsers < ActiveRecord::Migration
  def change
    add_index :weibo_users, :weibo_user_id
  end
end
