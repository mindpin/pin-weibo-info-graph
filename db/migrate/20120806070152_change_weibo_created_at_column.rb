class ChangeWeiboCreatedAtColumn < ActiveRecord::Migration
  def change
    rename_column :weibo_comments, :comment_created_at, :weibo_created_at
    rename_column :weibo_statuses, :status_created_at, :weibo_created_at
  end
end
