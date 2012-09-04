class WeiboUser < ActiveRecord::Base
  has_many :weibo_statuses, 
           :class_name => 'WeiboStatus', :order => 'weibo_status_id desc',
           :foreign_key => :weibo_user_id, :primary_key => :weibo_user_id

  has_many :retweeted_statuses, 
           :class_name => 'WeiboStatus', :order => 'created_at',
           :foreign_key => :weibo_user_id, :primary_key => :weibo_user_id,
           :conditions => ["retweeted_status_id != ''"]

  has_many :bilateral_friendships, 
           :class_name => 'BilateralFriendship',
           :foreign_key => :weibo_user_id

  validates :weibo_user_id, :uniqueness => true

  def self.create_by_api_hash(user)
    return if user.blank?
    weibo_user = WeiboUser.find_by_weibo_user_id(user['id'])

    attrs = {
      :screen_name => user['screen_name'],
      :profile_image_url => user['profile_image_url'],
      :gender  => user['gender'],
      :description => user['description'],
      :json => user.to_json
    }

    if weibo_user.blank?
      weibo_user = WeiboUser.create(attrs.merge(:weibo_user_id => user['id']))
    else
      weibo_user.update_attributes(attrs)
    end
    weibo_user
  end

  def self.search(client,query)
    response = client.search.suggestions_users(query).body
    users = ActiveSupport::JSON.decode response
    return [] if users.blank?

    users.map do |user|
      user_info = client.users.show(:uid => user['uid']).parsed
      WeiboUser.create_by_api_hash(user_info)
    end
  end

  def friends_bilateral(weibo_client)
    api_name = 'friendships/friends/bilateral'
    api_params = {:uid => self.weibo_user_id}.hash.to_s


    # 先判断在数据库是否有cache, 并且时间不超过 1 小时
    api_cache = WeiboApiCache.where(:api_name => api_name, :api_params => api_params)
    if api_cache.exists? && (Time.now < api_cache.first.updated_at + 1.hour)
      bilateral_users = WeiboApiCache.bilateral(self.weibo_user_id)
      user_data = []
      bilateral_users.each do |bilateral|
        user_data << WeiboUser.find_by_weibo_user_id(bilateral.other_weibo_user_id)
      end

      return user_data
    end
    
    # 再从 api 获取 
    response = weibo_client.friendships.friends_bilateral(self.weibo_user_id).parsed
    users = response['users']

    if api_cache.exists?
      api_cache.first.updated_at = Time.now
      api_cache.first.save

      # 清除已经存在的互相关注
      BilateralFriendship.delete_all(:weibo_user_id => self.weibo_user_id)
    else
      WeiboApiCache.create(:api_name => api_name, :api_params => api_params)
    end
    
    user_data = []
    users.map do |user|
      user_data << WeiboUser.create_by_api_hash(user)

      BilateralFriendship.create(
        :weibo_user_id => self.weibo_user_id, 
        :other_weibo_user_id => user['id']
      )
    end
    user_data.compact

    # users.map {|user_info|WeiboUser.create_by_api_hash(user_info)}.compact
  end

  def refresh_statuses(client)
    params = {:uid => self.weibo_user_id}
    newest_status = self.weibo_statuses.first
    if !newest_status.blank?
      params[:since_id] = newest_status.weibo_status_id
    end

      # 先根据 api 获取微博列表
    weibo_statuses = loop_to_request_weibo_api(200) do |current_page|
      user_weibo = client.statuses.user_timeline(params.merge(:page => current_page, :count => 20)).parsed
      user_weibo['statuses']
    end

    weibo_statuses.each{|status|WeiboStatus.create_by_api_hash(status)}
  end

  def json_hash
    ActiveSupport::JSON.decode(self.json)
  end

  STOP_WORDS = begin
    file = File.new File.expand_path(Rails.root.to_s + '/lib/stopwords.txt')
    file.read.split("\r\n") - ['']
  end

  def word_stats
    
    statuses = self.weibo_statuses

    _combine_statuses(statuses)
  end

  def _prepate_text(status_text)
    s1 = status_text.gsub /@\S+/, ''
    # s2 = s1.gsub /http:\/\/t.cn\/\S+/, ''
    s2 = s1.gsub /http:\/\/\S+/, ''
  end


  def _combine_statuses(statuses)
    words = Hash.new(0)

    statuses.each do |status|

      algor = RMMSeg::Algorithm.new(_prepate_text(status.text))
    
      loop do
        tok = algor.next_token
        break if tok.nil?

        word = tok.text
        if !STOP_WORDS.include?(word) && word.split(//u).length > 1
          words[word] = words[word] + 1
        end
      end
    end

    words
  end

  # -----------
  

  
  def group_retweeted_statuses
    WeiboStatistics.group_data(self.retweeted_statuses)
  end


  def group_word_stats_of_statuses
    statuses = self.weibo_statuses

    year_statuses = WeiboStatistics.group_data(statuses)
    group_statuses = WeiboStatistics.statuses_by_year_data(year_statuses)

    years_data = {}
    week_words = {}
    group_statuses.each do |year, week_data|
      week_data.each do |week, statuses|
        week_words[week] = _combine_statuses(statuses)
      end

      years_data[year] = week_words
    end

    years_data
  end


  def relation(client, other_weibo_user)
    relations = []

    self_friends = self.friends_bilateral(client)

    # self <=> other_weibo_user
    if self_friends.include?(other_weibo_user)
      relations << [self, other_weibo_user]
    end

    # self <=> xxx_1 <=> other_weibo_user
    other_weibo_user_friends = other_weibo_user.friends_bilateral(client)
    common_friends = other_weibo_user_friends & self_friends
    common_friends.each do |weibo_user|
      relations << [self, weibo_user, other_weibo_user]
    end
    
=begin 

    # self <=> xxx_1 <=> xxx_2 <=> other_weibo_user
    # self <=> xxx_1 <=> xxx <=> xxx_2 <=> other_weibo_user
    # self_friends_friends = {
    #   friend_a => [friend_a_friends],
    #   friend_b => [friend_b_friends]
    # }
    self_friends_friends = {}
    self_friends.each do |weibo_user|
      self_friends_friends[weibo_user] = weibo_user.friends_bilateral(client)
    end

    other_weibo_user_friends_friends = {}
    other_weibo_user_friends.each do |weibo_user|
      other_weibo_user_friends_friends[weibo_user] = weibo_user.friends_bilateral(client)
    end

    # self <=> xxx_1 <=> xxx_2 <=> other_weibo_user
    self_friends_friends.each do |friend, friend_friends|
      common_friends = friend_friends & other_weibo_user_friends
      common_friends.each do |weibo_user|
        relations << [self, friend, weibo_user, other_weibo_user]
      end
    end

    # self <=> xxx_1 <=> xxx <=> xxx_2 <=> other_weibo_user
    self_friends_friends.each do |self_friend, self_friend_friends|
      other_weibo_user_friends_friends.each do |other_friend, other_friend_friends|
        common_friends = self_friend_friends & other_friend_friends
        common_friends.each do |weibo_user|
          relations << [self, self_friend, weibo_user, other_friend, other_weibo_user]
        end
      end
    end
=end

    relations
  end




  # 用户 descriptions 分词，同时储存使用相应关键字对应的用户列表
  def combine_descriptions(users)
    data = Hash.new
    words = Hash.new(0)
    people = Hash.new

    users.each do |user|

      algor = RMMSeg::Algorithm.new(_prepate_text(user['description']))
    
      loop do
        tok = algor.next_token
        break if tok.nil?

        word = tok.text
        if !STOP_WORDS.include?(word) && word.split(//u).length > 1
          words[word] = words[word] + 1
          (people[word] ||= []) << user['screen_name']
          people[word] = people[word].uniq

          # 储存用户
          self.class.create_by_api_hash(user)
        end


      end
    end

    data['words'] = words.sort {|a1, a2| a2[1].to_i <=> a1[1].to_i }
    data['people'] = people

    data
  end



end
