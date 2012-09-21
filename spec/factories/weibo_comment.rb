FactoryGirl.define do
  factory :weibo_comment do
    sequence(:weibo_comment_id, 9) {|n| "5#{n}77051065284599" }
    sequence(:text, 9) {|n| "text #{n}" }
    weibo_user_id "2272194681"
    weibo_status_id "3474617715200562"
    weibo_created_at { 10.years.ago }
    to_weibo_user_id { |c| c.association(:weibo_user) }
    json "empty data for test"
  end
end
