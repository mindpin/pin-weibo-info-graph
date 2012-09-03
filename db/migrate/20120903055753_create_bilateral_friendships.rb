class CreateBilateralFriendships < ActiveRecord::Migration
  def change
    create_table :bilateral_friendships do |t|
      t.integer :weibo_user_id
      t.integer :other_weibo_user_id

      t.timestamps
    end
  end
end
