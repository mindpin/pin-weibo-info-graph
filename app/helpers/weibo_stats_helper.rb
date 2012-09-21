module WeiboStatsHelper
  # 根据当前第几周，返回日期范围
  def week_dates(year,  week_number)
      week_start = Date.commercial( year, week_number, 1 )
      week_end = Date.commercial( year, week_number, 7 )
      week_start.strftime( "%m/%d/%y" ) + ' - ' + week_end.strftime( 
  "%m/%d/%y" )
  end

  def users_by_received_comments(received_comments)
    years = {}
    begin
      received_comments.each do |year, week_data|
        next if week_data.nil?

        weeks = Hash.new(0)
        week_data.each do |week|
          weibo_users = Hash.new(0)

          # week_index = Date.parse(week[0].weibo_created_at.to_s).cweek

          week[1].each do |row|
            next if row.weibo_user_id.nil?
            weibo_users[row.weibo_user_id] += 1
          end

          weeks[week[0]] = weibo_users
        end

        years[year] = weeks.to_hash
      end
    rescue
    end

    years
  end  
end
