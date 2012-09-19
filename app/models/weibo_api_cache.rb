class WeiboApiCache < ActiveRecord::Base

  def self.bilateral(weibo_client, weibo_user)
    cache = BilateralCache.new(weibo_client, weibo_user)
    cache.bilateral
    cache.friend_weibo_users
  end


  def self.show(weibo_client, opts={})
    api_name = 'users/show'
    api_params = opts.hash.to_s
    api_cache = WeiboApiCache.where(:api_name => api_name, :api_params => api_params).first

    if api_cache.blank?
      WeiboApiCache.create(:api_name => api_name, :api_params => api_params)

      user_info = weibo_client.users.show(opts).parsed
      WeiboUser.create_by_api_hash(user_info)
    else
      api_cache.touch
    end

    if !api_cache.nil? && (Time.now > api_cache.updated_at + 1.hour)
      user_info = weibo_client.users.show(opts).parsed
      WeiboUser.create_by_api_hash(user_info)
    end

    return WeiboUser.find_by_weibo_user_id(opts['uid']) if opts['uid']
    return WeiboUser.find_by_screen_name(opts['screen_name']) if opts['screen_name']
    
  end


  def self.friends(weibo_client, weibo_user)
    cache = FriendsCache.new(weibo_client, weibo_user)
    cache.friends
    cache.friend_weibo_users
  end

end
