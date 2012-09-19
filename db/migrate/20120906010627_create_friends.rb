class CreateFriends < ActiveRecord::Migration
  def change
    create_table :friends do |t|
      t.integer :weibo_user_id, :limit => 8
      t.integer :other_weibo_user_id, :limit => 8

      t.timestamps
    end
  end
end
