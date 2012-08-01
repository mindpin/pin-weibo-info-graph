class ChangeUidFromUserWeiboAuths < ActiveRecord::Migration
  def change
    rename_column :user_weibo_auths, :uid, :weibo_user_id
  end
end
