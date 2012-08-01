class WeiboCommentsController < ApplicationController 

  def index
    unless params[:screen_name].nil?
      weibo_user = WeiboUser.find_by_screen_name(params[:screen_name])
      begin
        comments = weibo_user.get_all_comments(current_user)

        weibo_user.store_comments(comments)

        @comments = WeiboComment.all
      rescue
        p 'user not in database'
      end
    end
  end


  def show
    @weibo_status = WeiboStatus.find_by_weibo_status_id(params[:id])
    @weibo_user = @weibo_status.weibo_user
    @weibo_comments = WeiboComment.find_all_by_weibo_status_id(params[:id])
  end


  def refresh
    WeiboComment.update_by_weibo_status_id(current_user, params[:weibo_status_id])
    redirect_to :back
  end

end
