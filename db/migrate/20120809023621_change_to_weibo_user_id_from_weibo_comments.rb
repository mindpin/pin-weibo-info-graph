class ChangeToWeiboUserIdFromWeiboComments < ActiveRecord::Migration
  def change
    change_column :weibo_comments, :to_weibo_user_id, :integer, :limit => 8
  end
end
