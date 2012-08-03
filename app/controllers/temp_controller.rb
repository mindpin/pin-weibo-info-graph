class TempController < ApplicationController
  before_filter :login_required


  def fix_date

    WeiboStatus.all.each do |status|
      weibo = JSON.parse status.json

      status.status_created_at = Date.parse(weibo['created_at']).to_s
      status.save
    end

    render :nothing => true
  end


end
