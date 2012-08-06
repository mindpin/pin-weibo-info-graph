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
    words = Hash.new(0)
    statuses = self.weibo_statuses

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

  def _prepate_text(status_text)
    s1 = status_text.gsub /@\S+/, ''
    # s2 = s1.gsub /http:\/\/t.cn\/\S+/, ''
    s2 = s1.gsub /http:\/\/\S+/, ''
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




  def group_statuses
    year_statuses = {}
    statuses = self.retweeted_statuses

    first_status_year = statuses.first.status_created_at.year
    last_status_year = statuses.last.status_created_at.year

    if first_status_year == last_status_year
      year_statuses[first_status_year] = statuses
    else
      statuses.each do |status|
        year = status.status_created_at.year
        (year_statuses[year] ||= []) << status
      end
    end

    year_statuses.each do |year, statuses|
      year_statuses[year] = group_year_statuses_by_week(statuses)
    end

    year_statuses
  end



  def group_year_statuses_by_week(statuses)
    week_statuses = []

    start_date = Date.parse(statuses.first.status_created_at.to_s)
    end_date = Date.parse(statuses.last.status_created_at.to_s)
    
    first_week_days = 7 - statuses.first.status_created_at.wday
    end_week_date = start_date + first_week_days

    if end_week_date >= end_date
      week_statuses << statuses
    else
      temp_statuses = []
      statuses.each do |status|
        if status.status_created_at <= end_week_date
          temp_statuses << status
        end
      end

      week_statuses << temp_statuses
      week_statuses = self.divide_week_statuses(week_statuses, statuses)
    end

    week_statuses
    
  end

  def divide_week_statuses(week_statuses, statuses)
    last_week_statuses = week_statuses.last
    end_week_date = Date.parse(last_week_statuses.last.status_created_at.to_s) + 7
    end_date = Date.parse(statuses.last.status_created_at.to_s)


    temp_statuses = []
    last_week_date = Date.parse(last_week_statuses.last.status_created_at.to_s)


    if end_week_date < end_date
      
      statuses.each do |status|
        current_date = Date.parse(status.status_created_at.to_s)
        if current_date > last_week_date && current_date <= end_week_date
          temp_statuses << status
        end
      end
      week_statuses << temp_statuses
      self.divide_week_statuses(week_statuses, statuses)
    else
      end_week_date = last_week_date + 6
      statuses.each do |status|
        current_date = Date.parse(status.status_created_at.to_s)
        if current_date > last_week_date && current_date <= end_week_date
          temp_statuses << status
        end
      end
      week_statuses << temp_statuses
      return week_statuses
      
    end
  end



 
end
