module WeiboCommentsHelper

  # 根据当前第几周，返回日期范围
  def week_dates( week_num )
      year = Time.now.year
      week_start = Date.commercial( year, week_num, 1 )
      week_end = Date.commercial( year, week_num, 7 )
      week_start.strftime( "%m/%d/%y" ) + ' - ' + week_end.strftime( 
  "%m/%d/%y" )
  end

  def interactive_by_week_comments(week_comments)

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


  def interactive_by_week_retweeted(week_retweeted_statuses)
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


  def interactive_by_comments_and_retweeted(week_comments, week_retweeted_statuses)
    comment_users = interactive_by_week_comments(week_comments)
    retweeted_users = interactive_by_week_retweeted(week_retweeted_statuses)

    #p comment_users
    #p retweeted_users
    #p 777777777777777777777777777777777

    users = Hash.new(0)
    comment_users.each_with_index do |comment, index|
      comment_week_number = comment[0]
      comment_week = comment[1]

      retweeted_users.each do |retweeted|
        retweeted_week_number = retweeted[0]
        retweeted_week = retweeted[1]

        if comment_week_number == retweeted_week_number
          users[comment_week_number]= comment_week.merge(retweeted_week) do |key, oldval, newval| 
            newval + oldval
          end
        end
      end


    end

    #p users

    users = comment_users.merge(users)
    users = retweeted_users.merge(users)

    #p users

    users


  end

end
