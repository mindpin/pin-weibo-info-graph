class CreateWeiboUsers < ActiveRecord::Migration
  def change
    create_table :weibo_users do |t|
      t.integer :weibo_user_id, :limit => 8
      t.string :screen_name
      t.string :profile_image_url
      t.string :gender
      t.text :description
      t.text :json # 微博 user 的 json 原始信息

      t.timestamps
    end

  end
end
