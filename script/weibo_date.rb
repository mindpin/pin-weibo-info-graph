WeiboStatus.all.each do |status|
  weibo = JSON.parse status.json

  status.weibo_created_at = Date.parse(weibo['created_at']).to_s
  status.save
end