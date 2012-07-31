class WeiboCommentsController < ApplicationController
  def index
    unless params[:screen_name].nil?
      weibo_user = WeiboUser.find_by_screen_name(params[:screen_name])
      begin
        comments = weibo_user.get_all_comments(current_user)

        weibo_user.store_comments(comments)
      rescue
        p 'user not in database'
      end
    end
  end
end
