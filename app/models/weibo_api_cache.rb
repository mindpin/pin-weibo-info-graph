class WeiboApiCache < ActiveRecord::Base
  def self.bilateral(weibo_user_id)
    # weibo_user = WeiboUser.find_by_screen_name(screen_name)
    bilateral_users = BilateralFriendship.where(:weibo_user_id => weibo_user_id)

    bilateral_users.map! do |bilateral|
      WeiboUser.find_by_weibo_user_id(bilateral.other_weibo_user_id)
    end
  end


  def self.get_bilateral_users(api_name, api_params)
    api_cache = WeiboApiCache.where(:api_name => api_name, :api_params => api_params)
    if api_cache.exists? && (Time.now < api_cache.first.updated_at + 1.hour)
      api_cache.first.updated_at = Time.now
      api_cache.first.save

      # 清除已经存在的互相关注
      BilateralFriendship.delete_all(:weibo_user_id => self.weibo_user_id)

      return WeiboApiCache.bilateral(self.weibo_user_id)
    else
      WeiboApiCache.create(:api_name => api_name, :api_params => api_params)
    end

    return nil
  end
end
