class BilateralCache
  attr_reader :friend_weibo_users
  def initialize(weibo_client, weibo_user)
    @weibo_client = weibo_client
    @weibo_user = weibo_user
    @api_name = 'friendships/friends/bilateral'
    @api_params = {:uid => @weibo_user.weibo_user_id}.hash.to_s
    @api_cache = WeiboApiCache.where(:api_name => @api_name, :api_params => @api_params).first
    @expire_in = 1.hour
  end

  def bilateral
    @friend_weibo_users = bilateral_from_cache
    return if !@friend_weibo_users.blank?

    @friend_weibo_users = bilateral_from_api
    update_bilateral_cache
  end

  private
  def bilateral_from_cache
    weibo_users = []
    if !@api_cache.blank? && (Time.now < @api_cache.updated_at + @expire_in)
      friendships = BilateralFriendship.where(:weibo_user_id => @weibo_user.weibo_user_id)
      weibo_users = friendships.map do |friendship|
        WeiboUser.find_by_weibo_user_id(friendship.other_weibo_user_id)
      end
    end

    weibo_users
  end

  def bilateral_from_api
    response = @weibo_client.friendships.friends_bilateral(@weibo_user.weibo_user_id).parsed
    users = response['users']

    users_count = users.count
    next_page = 2
    while users_count < response['total_number']
      response = @weibo_client.friendships.friends_bilateral(:uid => @weibo_user.weibo_user_id, :page => next_page).parsed
      users += response['users']

      users_count += users.count
      next_page += 1
    end

    users.map {|user_info|WeiboUser.create_by_api_hash(user_info)}.compact
  end

  def update_bilateral_cache
    if @api_cache.blank?
      WeiboApiCache.create(:api_name => @api_name, :api_params => @api_params)
    else
      @api_cache.touch
      BilateralFriendship.delete_all(:weibo_user_id => @weibo_user.weibo_user_id)
    end

    @friend_weibo_users.each do |other_weibo_user|
      BilateralFriendship.create(
        :weibo_user_id => @weibo_user.weibo_user_id, 
        :other_weibo_user_id => other_weibo_user.weibo_user_id
      )
    end
  end
end