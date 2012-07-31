class IndexController < ApplicationController
  def index
    if logged_in?
      return redirect_to '/weibo'
    end
    
    # 如果还没有登录，渲染登录页
    return render :template=>'index/login'

  end

end
