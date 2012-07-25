class CreateUserWeiboAuths < ActiveRecord::Migration
  def change
    create_table :user_weibo_auths do |t|
      t.integer :user_id
      t.string :auth_code

      t.timestamps
    end
  end
end
