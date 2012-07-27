class CreateWeiboStatuses < ActiveRecord::Migration
  def change
    create_table :weibo_statuses do |t|
      t.integer   :weibo_status_id, :limit => 8 # 微博 id, 长整形 
      t.integer :weibo_user_id, :limit => 8 # 微博作者 id, 长整形 
      t.string :text # 微博正文 
      t.integer :retweeted_status_id, :limit => 8 # 被转发的微博 id, 长整形
      t.string :bmiddle_pic # 中等尺寸图片地址
      t.string :original_pic # 原始图片地址
      t.string :thumbnail_pic # 缩略图片地址
      t.text :json # 微博的 json 原始信息 

      t.timestamps
    end

  end
end
