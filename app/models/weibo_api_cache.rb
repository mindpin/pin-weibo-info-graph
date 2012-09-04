class WeiboApiCache < ActiveRecord::Base

  def self.bilateral(weibo_client, weibo_user)
    cache = BilateralCache.new(weibo_client, weibo_user)
    cache.bilateral
    cache.friend_weibo_users
  end

end
