class CreateWeiboDateToStatusesAndComments < ActiveRecord::Migration
  def up
    add_column :weibo_statuses, :status_created_at, :date
    add_column :weibo_comments, :comment_created_at, :date
  end
end
