class WeiboUser < ActiveRecord::Base
  has_many :weibo_statuses, 
           :class_name => 'WeiboStatus', :order => 'created_at',
           :foreign_key => :weibo_user_id, :primary_key => :weibo_user_id


  has_many :retweeted_statuses, 
           :class_name => 'WeiboStatus', :order => 'created_at',
           :foreign_key => :weibo_user_id, :primary_key => :weibo_user_id,
           :conditions => ["retweeted_status_id != ''"]


  validates_uniqueness_of :weibo_user_id

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
  
  def get_all_comments(client_user)
    client = client_user.get_weibo_client

    statuses = self.weibo_statuses
    if !statuses.nil? && statuses.any?
      comments = []
      statuses.each do |status|
        response = client.comments.show(status.weibo_status_id).parsed
        comments = comments + response['comments']
      end
    end

    comments
  end
  # end of get_all_comments

  
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

 
end
