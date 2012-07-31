class CreateWeiboComments < ActiveRecord::Migration
  def change
    create_table :weibo_comments do |t|
      t.integer :weibo_comment_id, :limit => 8 # 评论 id, 长整形
      t.string :text # 评论正文
      t.integer :weibo_user_id, :limit => 8 # 创建这条评论的用户 id, 长整形
      t.integer :weibo_status_id, :limit => 8 # 所属的微博的 id, 长整形

      t.timestamps
    end
  end
end
