require 'spec_helper'

describe UserWeiboAuth do

  before do
    @current_weibo_user = FactoryGirl.create(:user_weibo_auth)

    FactoryGirl.create_list(:weibo_comment, 2, :weibo_created_at => '2001-06-09')
    FactoryGirl.create_list(:weibo_comment, 3, :weibo_created_at => '2011-02-17')
    FactoryGirl.create_list(:weibo_comment, 1, :weibo_created_at => '2011-02-09')
  end

  it '微博评论互动统计' do
    comments = @current_weibo_user.group_my_comments

    # p comments

    comments.keys.should include(2011)
    comments.keys.should include(2001)
  end

  

end