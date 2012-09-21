class WeiboStatistics

  # 数据分组对象，
  # 根据一周为单位对数据进行分组
  class DataWeekGroupList
    def initialize(items)
      @hash = Hash.new

      items.each do |item|
        self.put(item)
      end
    end

    # 根据 item 所处的年和星期来把 item 放入合适的子分组
    def put(item)
      date = item.data_created_at.to_date
      year, week = date.year, date.cweek
      weibo_user = item.weibo_user

      hash_key = [year, week, weibo_user].hash

      @hash[hash_key] ||= WeekData.new(year, week)
      @hash[hash_key].put(item)
    end

    # 返回结果数组，并按照年和周顺序排好序
    def get_result
      return @hash.values
    end

    class WeekData
      attr_reader :year, :week, :list

      def initialize(year, week)
        @year, @week = year, week
        @list = []
      end

      def put(item)
        @list << item
      end

      def each(&block)
        @list.each(&block)
      end

      # 获取互动统计信息，返回结果为一个 hash
      def get_interactive_stat
        result = Hash.new(0)

        @list.each do |item|
          to_weibo_user = item.to_weibo_user
          result[to_weibo_user] += 1
        end

        return result
      end
    end
  end

  def self.group_data_by_week(items)
    group_list = DataWeekGroupList.new(items)
    return group_list.get_result
  end


  # def self.group_data(data)
  #   year_data = {}

  #   first_data_year = data.first.data_created_at.year
  #   last_data_year = data.last.data_created_at.year

  #   if first_data_year == last_data_year
  #     year_data[first_data_year] = data
  #   else
  #     data.each do |row|
  #       year = row.data_created_at.year
  #       (year_data[year] ||= []) << row
  #     end
  #   end

  #   year_data.each do |year, data|
  #     year_data[year] = group_year_data_by_week(data)
  #   end

  #   year_data
  # end


  def self.group_year_data_by_week(year_data)
    week_data = {}

    year_data.each do |row|
      week_number = row.data_created_at.to_date.cweek
      (week_data[week_number] ||= []) << row
    end
    
    week_data
  end

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