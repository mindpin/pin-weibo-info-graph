class WeiboUser < ActiveRecord::Base
  has_many :weibo_statuses, 
           :class_name => 'WeiboStatus', :order => 'weibo_status_id desc',
           :foreign_key => :weibo_user_id, :primary_key => :weibo_user_id


  has_many :retweeted_statuses, 
           :class_name => 'WeiboStatus', :order => 'created_at',
           :foreign_key => :weibo_user_id, :primary_key => :weibo_user_id,
           :conditions => ["retweeted_status_id != ''"]


  validates_uniqueness_of :weibo_user_id

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
      WeiboUser.create(attrs.merge(:weibo_user_id => user['id']))
    else
      weibo_user.update_attributes(attrs)
    end

  end

  def friends_bilateral(weibo_client)
    response = weibo_client.friendships.friends_bilateral(self.weibo_user_id).parsed
    users = response['users']

    users.map do |user_info|
      weibo_user = WeiboUser.find_by_weibo_user_id(user_info['id'])
      weibo_user = WeiboUser.create_by_api_hash(user_info) if weibo_user.blank?
      weibo_user
    end
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

  
  # 取得两个用户之间通过多少人可以联系起来
  def self.get_connections(user, weibo_user_a, weibo_user_b)
    a_friends = WeiboUser.get_friendships(user, weibo_user_a)
    connections = []

    # 第一层关系判断
    if a_friends.include?(weibo_user_b)
      return connections
    else
      b_friends = WeiboUser.get_friendships(user, weibo_user_b)

      # 第二层关系判断
      b_friends.each do |b_friend|
        if a_friends.include?(b_friend)
          connections << b_friend
        end
      end
      # 结束第二层关系判断

      # 第三层
      unless connections.any?
        b_friends.each do |b_friend|
          b_b_friends = WeiboUser.get_friendships(user, b_friend)
          b_b_friends.each do |b_b_friend|
            if a_friends.include?(b_b_friend)
              connections << b_friend
              connections << b_b_friend
              return connections
            end
          end
        end
      end

      unless connections.any?
        a_friends.each do |a_friend|
          a_a_friends = WeiboUser.get_friendships(user, a_friend)
          a_a_friends.each do |a_a_friend|
            if b_friends.include?(a_a_friend)
              connections << a_friend
              connections << a_a_friend
              return connections
            end
          end
        end
      end
      # 结束第三层


      # 第四层
      a_friends.each do |a_friend|
        a_a_friends = WeiboUser.get_friendships(user, a_friend)
        a_a_friends.each do |a_a_friend|
          b_friends.each do |b_friend|
            b_b_friends = WeiboUser.get_friendships(user, b_friend)
            if b_b_friends.include?(a_a_friend)
              connections << a_friend
              connections << a_a_friend
              connections << b_friend
              return connections
            end
          end
        end
      end
      # 结束第四层

    end
    # 结束第一层关系判断

    return nil
  end

  
  # 根据 screen_name 取当该微博用户关注粉丝
  def self.get_friendships(user, screen_name)
    if screen_name.blank?
      return []
    end

    client = user.weibo_auth.weibo_client
    user = client.users.show(:screen_name => screen_name).parsed

    friendships = []
    friends = client.friendships.friends_bilateral(user['id']).parsed
    if !friends['users'].nil? && friends['users'].any?
      friends['users'].each do |friend|
        friendships << friend['screen_name']
      end
    end

    friendships

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



  include WeiboComment::WeiboUserMethods

 
end
