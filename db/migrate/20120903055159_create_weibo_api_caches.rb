class CreateWeiboApiCaches < ActiveRecord::Migration
  def change
    create_table :weibo_api_caches do |t|
      t.string :api_name
      t.string :api_params

      t.timestamps
    end
  end
end
