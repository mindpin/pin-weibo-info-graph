FactoryGirl.define do
  factory :weibo_user do
    sequence(:weibo_user_id, 9) {|n| "169771419#{n}" }
    sequence(:screen_name, 9) {|n| "screen name #{n}" }
    profile_image_url "http://tp2.sinaimg.cn/1697714197/50/1266747313/1"
    gender "m"
    sequence(:description, 9) {|n| "description #{n}" }
    json "empty data for test"
  end
end
