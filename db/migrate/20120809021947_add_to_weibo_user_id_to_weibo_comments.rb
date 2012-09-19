class AddToWeiboUserIdToWeiboComments < ActiveRecord::Migration
  def change
    add_column :weibo_comments, :to_weibo_user_id, :integer
  end
end
