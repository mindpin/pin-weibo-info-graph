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
    week_data = {}

    year_data.each do |row|
      week_number = row.weibo_created_at.cweek
      (week_data[week_number] ||= []) << row
    end
    
    week_data
  end
  # end of group_year_data_by_week



  def self.users_by_year_data(year_data, type)

    return {} if year_data.blank?

    years = {}
    year_data.each do |year, week_data|
      years[year] = users_by_week_data(week_data, type)
    end

    years
  end


  def self.users_by_week_data(week_data, type)
    return {} if week_data.nil?
      
    weeks = Hash.new(0)
    week_data.each do |week|
      weibo_users = Hash.new(0)

      # week_index = Date.parse(week[0].weibo_created_at.to_s).cweek



      week[1].each do |row|
        if type == 'comment'
          # next if row.weibo_status.weibo_user.weibo_user_id.nil?
          # weibo_users[row.weibo_status.weibo_user.weibo_user_id] += 1

          weibo_users[row.to_weibo_user_id] += 1
        else
          next if row.retweeted_status.weibo_user_id.nil?
          weibo_users[row.retweeted_status.weibo_user_id] += 1
        end
      end

      weeks[week[0]] = weibo_users
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