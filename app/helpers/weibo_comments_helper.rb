module WeiboCommentsHelper

  def interactive_users_count(comments)

    weibo_users = Hash.new(0)

    comments.each do |comment|
      weibo_status = comment.weibo_status

      weibo_users[weibo_status.weibo_user.weibo_user_id] += 1

    end

    weibo_users

  end

end
