class AddJsonToWeiboComments < ActiveRecord::Migration
  def change
    add_column :weibo_comments, :json, :text
  end
end
