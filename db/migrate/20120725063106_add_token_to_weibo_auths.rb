class AddTokenToWeiboAuths < ActiveRecord::Migration
  def change
    add_column(:user_weibo_auths, :token, :string)
    add_column(:user_weibo_auths, :expires_in, :integer)
  end
end
