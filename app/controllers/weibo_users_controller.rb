class WeiboUsersController < ApplicationController
  def word_stats
    weibo_user = WeiboUser.find_by_weibo_user_id(params[:weibo_user_id])
    words = weibo_user.word_stats.sort {|a1, a2| a2[1].to_i <=> a1[1].to_i }

    @top_20_words = words[0..19]

  end
end
