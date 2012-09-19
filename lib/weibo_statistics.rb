class WeiboStatistics
  def self.group_data(data)
    year_data = {}

    first_data_year = data.first.weibo_created_at.year
    last_data_year = data.last.weibo_created_at.year

    if first_data_year == last_data_year
      year_data[first_data_year] = data
    else
      data.each do |row|
        year = row.weibo_created_at.year
        (year_data[year] ||= []) << row
      end
    end

    year_data.each do |year, data|
      year_data[year] = group_year_data_by_week(data)
    end

    year_data
  end
  # end of group_data


  def self.group_year_data_by_week(year_data)
    week_data = []

    start_date = Date.parse(year_data.first.weibo_created_at.to_s)
    end_date = Date.parse(year_data.last.weibo_created_at.to_s)
    
    first_week_days = 7 - year_data.first.created_at.wday
    end_week_date = start_date + first_week_days

    if end_week_date >= end_date
      week_data << year_data
    else
      temp_data = []
      year_data.each do |row|
        if row.weibo_created_at <= end_week_date
          temp_data << row
        end
      end

      week_data << temp_data
      week_data = self.divide_week_data(week_data, year_data, weibo_created_at)
    end

    week_data
  end
  # end of group_year_data_by_week




  def self.divide_week_data(week_data, year_data)
    last_week_comments = week_data.last
    end_week_date = Date.parse(last_week_comments.last.weibo_created_at.to_s) + 7
    end_date = Date.parse(year_data.last.weibo_created_at.to_s)


    temp_data = []
    last_week_date = Date.parse(last_week_comments.last.weibo_created_at.to_s)


    if end_week_date < end_date
      
      year_data.each do |row|
        current_date = Date.parse(row.weibo_created_at.to_s)
        if current_date > last_week_date && current_date <= end_week_date
          temp_data << row
        end
      end
      week_data << temp_data
      self.divide_week_comments(week_data, year_data)
    else
      end_week_date = last_week_date + 6
      year_data.each do |row|
        current_date = Date.parse(row.weibo_created_at.to_s)
        if current_date > last_week_date && current_date <= end_week_date
          temp_data << row
        end
      end
      week_data << temp_data
      return week_data
      
    end
  end
  # end of divide_week_data


  def self.users_by_year_data(year_data, type)
    years = {}
    begin
      year_data.each do |year, week_data|
        years[year] = users_by_week_data(week_data, type)
      end
    rescue
    end

    years
  end


  def self.users_by_week_data(week_data, type)
    if week_data.nil?
      return {}
    end

    weeks = Hash.new(0)
    week_data.each do |week|
      weibo_users = Hash.new(0)

      week_index = Date.parse(week[0].weibo_created_at.to_s).cweek

      week.each do |row|
        if type == 'comment'
          next if row.weibo_status.weibo_user.weibo_user_id.nil?
          weibo_users[row.weibo_status.weibo_user.weibo_user_id] += 1
        else
          next if row.retweeted_status.weibo_user_id.nil?
          weibo_users[row.retweeted_status.weibo_user_id] += 1
        end
      end

      weeks[week_index] = weibo_users
    end

    weeks.to_hash

  end



  def self.statuses_by_year_data(year_data)
    years = {}
    year_data.each do |year, week_data|
      years[year] = statuses_by_week_data(week_data)
    end

    years
  end


  def self.statuses_by_week_data(week_data)
    if week_data.nil?
      return {}
    end

    weeks = Hash.new(0)
    week_data.each do |week|
      weibo_statuses = []

      week_index = Date.parse(week[0].weibo_created_at.to_s).cweek

      week.each do |row|
        weibo_statuses << row
      end

      weeks[week_index] = weibo_statuses
    end

    weeks.to_hash

  end



end