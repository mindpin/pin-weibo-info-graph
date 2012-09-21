class ChangeCreatedAtOfWeiboComments < ActiveRecord::Migration
  def change
  	change_column :weibo_comments, :weibo_created_at, :datetime
    rename_column :weibo_comments, :weibo_created_at, :data_created_at
  end
end
