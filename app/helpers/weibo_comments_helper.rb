module WeiboCommentsHelper

  # 根据当前第几周，返回日期范围
  def week_dates( year,  week_num )
      week_start = Date.commercial( year, week_num, 1 )
      week_end = Date.commercial( year, week_num, 7 )
      week_start.strftime( "%m/%d/%y" ) + ' - ' + week_end.strftime( 
  "%m/%d/%y" )
  end


  def interactive_by_year_comments(year_comments)
    years = {}
    year_comments.each do |year, comments|
      years[year] = interactive_by_week_comments(comments)
    end

    years
  end

  def interactive_by_week_comments(week_comments)
    if week_comments.nil?
      return {}
    end

    weeks = Hash.new(0)
    week_comments.each do |week|
      weibo_users = Hash.new(0)

      week_index = Date.parse(week[0].created_at.to_s).cweek

      week.each do |comment|
        weibo_users[comment.weibo_status.weibo_user.weibo_user_id] += 1
      end

      weeks[week_index] = weibo_users
    end

    weeks.to_hash

  end


  def interactive_by_year_retweeted(year_retweeted)
    years = {}
    year_retweeted.each do |year, retweeted|
      years[year] = interactive_by_week_retweeted(retweeted)
    end

    years
  end


  def interactive_by_week_retweeted(week_retweeted_statuses)
    if week_retweeted_statuses.nil?
      return
    end

    weeks = Hash.new(0)
    week_retweeted_statuses.each do |week|
      weibo_users = Hash.new(0)
      week_index = Date.parse(week[0].created_at.to_s).cweek

      week.each do |status|
        weibo_users[status.retweeted_status.weibo_user_id] += 1
      end

      weeks[week_index] = weibo_users
    end

    weeks.to_hash

  end


  def interactive_by_comments_and_retweeted(year_comments, year_retweeted_statuses)
    comment_users = interactive_by_year_comments(year_comments)
    retweeted_users = interactive_by_year_retweeted(year_retweeted_statuses)

    if comment_users.nil?
      return retweeted_users unless retweeted_users.nil?
    end

    if retweeted_users.nil?
      return comment_users unless comment_users.nil?
    end

    years = []
    years += comment_users.keys
    years += retweeted_users.keys
    years = years.uniq

    #p years

    users = {}
    years.each do |year|
      users[year] = {}
      if comment_users.has_key?(year) && !retweeted_users.has_key?(year)
        p 11111111111111111111111111111111111111111111111111
        users[year] = comment_users[year]
      end

      if !comment_users.has_key?(year) && retweeted_users.has_key?(year)
        p 222222222222222222222222222222222222222222222222222222222222222222222222
        users[year] = retweeted_users[year]
      end

      if comment_users.has_key?(year) && retweeted_users.has_key?(year)
        p 333333333333333333333333333333333333333333333333
        year_comment_users = comment_users[year]
        year_retweeted_users = retweeted_users[year]


        weeks = []
        weeks += year_comment_users.keys
        weeks += year_retweeted_users.keys
        weeks = weeks.uniq

        p 99999
        p year_comment_users.keys
        p year_retweeted_users.keys
        p weeks
        p 88888

        weeks.each do |week|
          if year_comment_users.has_key?(week) && !year_retweeted_users.has_key?(week)
            p 444444444444444444444444444444444444444444
            users[year][week] = year_comment_users[week]
          end

          if !year_comment_users.has_key?(week) && year_retweeted_users.has_key?(week)
            p 555555555555555555555555555555555555555555555555
            users[year][week] = year_retweeted_users[week]
          end

          if year_comment_users.has_key?(week) && year_retweeted_users.has_key?(week)

            p 666666666666666666666666666666666666666666666666666666666666666666666666666666
            users[year][week] = year_comment_users[week].merge(year_retweeted_users[week]) do |key, oldval, newval| 
              newval + oldval
            end
          end
        end
        # end of weeks

      end

    end
    # end of years


    #p users

    users


  end

end
