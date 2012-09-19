class FriendsCache
  attr_reader :friend_weibo_users
  def initialize(weibo_client, weibo_user)
    @weibo_client = weibo_client
    @weibo_user = weibo_user
    @api_name = 'friendships/friends'
    @api_params = {:uid => @weibo_user.weibo_user_id}.hash.to_s
    @api_cache = WeiboApiCache.where(:api_name => @api_name, :api_params => @api_params).first
    @expire_in = 1.hour
  end

  def friends
    @friend_weibo_users = friends_from_cache
    return if !@friend_weibo_users.blank?

    @friend_weibo_users = friends_from_api
    update_friends_cache
  end

  private
  def friends_from_cache
    weibo_users = []
    if !@api_cache.blank? && (Time.now < @api_cache.updated_at + @expire_in)
      friends = Friend.where(:weibo_user_id => @weibo_user.weibo_user_id)
      weibo_users = friends.map do |friend|
        WeiboUser.find_by_weibo_user_id(friend.other_weibo_user_id)
      end
    end

    weibo_users
  end

  def friends_from_api
    # response = @weibo_client.friendships.friends(@weibo_user.weibo_user_id).parsed
    # users = response['users']


    friends = @weibo_client.friendships.friends(:uid => @weibo_user.weibo_user_id).parsed
    friend_weibo_users = friends['users'].map {|user| WeiboUser.create_by_api_hash(user)}

    while true
      if friends['next_cursor'] > 0
        friends = @weibo_client.friendships.friends(:uid => @weibo_user.weibo_user_id, :cursor => friends['next_cursor']).parsed
        friend_weibo_users += friends['users'].map {|user| WeiboUser.create_by_api_hash(user)}
      else
        break
      end
    end
    friend_weibo_users

    # users.map {|user_info|WeiboUser.create_by_api_hash(user_info)}.compact
  end

  def update_friends_cache
    if @api_cache.blank?
      WeiboApiCache.create(:api_name => @api_name, :api_params => @api_params)
    else
      @api_cache.touch
      Friend.delete_all(:weibo_user_id => @weibo_user.weibo_user_id)
    end

    @friend_weibo_users.each do |other_weibo_user|
      Friend.create(
        :weibo_user_id => @weibo_user.weibo_user_id, 
        :other_weibo_user_id => other_weibo_user.weibo_user_id
      )
    end
  end
end