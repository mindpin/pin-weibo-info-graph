class AddBasicInfoToUserWeiboAuths < ActiveRecord::Migration
  def change
    add_column :user_weibo_auths, :uid, :integer, :limit => 8 # 长整形
    add_column :user_weibo_auths, :screen_name, :string
    add_column :user_weibo_auths, :avatar, :string
  end
end
