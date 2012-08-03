class TempController < ApplicationController
  before_filter :login_required

  def index
    uid = '1134880297'
    since_id = '3472452866592554'

    client = current_user.get_weibo_client
    user_weibo = client.statuses.user_timeline(:uid => uid, :count => 10).parsed
    p user_weibo
    render :nothing => true
  end


  def fix_date
    client = current_user.get_weibo_client

    WeiboStatus.all.each do |status|
      weibo = client.statuses.show(status.weibo_status_id).parsed
      status.status_created_at = Date.parse(weibo['created_at']).to_s
      status.save
    end
    

    render :nothing => true
  end


end
