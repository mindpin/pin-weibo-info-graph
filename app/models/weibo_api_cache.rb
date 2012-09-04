class WeiboApiCache < ActiveRecord::Base
  def self.bilateral(weibo_user_id)
    # weibo_user = WeiboUser.find_by_screen_name(screen_name)
    BilateralFriendship.where(:weibo_user_id => weibo_user_id)
  end
end
