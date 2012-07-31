class WeiboUser < ActiveRecord::Base
  has_many :weibo_statuses, 
           :class_name => 'WeiboStatus', 
           :foreign_key => :weibo_user_id, :primary_key => :weibo_user_id

  #set_primary_key :weibo_user_id # 重新设置关联主键，不使用默认的 id 字段

  validates_uniqueness_of :weibo_user_id


  STOP_WORDS = begin
    arr = []
    file = File.new File.expand_path(Rails.root.to_s + '/lib/stopwords.txt')
    file.read.split("\r\n")
  end


  def word_stats
    words = Hash.new(0)
    statuses = self.weibo_statuses

    statuses.each do |status|

      algor = RMMSeg::Algorithm.new(status.text)
    
      loop do
        tok = algor.next_token
        break if tok.nil?
        words[tok.text] = words[tok.text] + 1 unless STOP_WORDS.include?(tok.text)

      end
    end

    words
  end
  # end of word_stats

  
  def get_all_comments(client_user)
    client = client_user.get_weibo_client

    statuses = self.weibo_statuses
    if !statuses.nil? && statuses.any?
      comments = []
      statuses.each do |status|
        response = client.comments.show(status.weibo_status_id).parsed
        comments = comments + response['comments']
      end
    end

    comments
  end
  # end of get_all_comments


  def store_comments(comments)
    unless comments.nil?
      comments.each do |comment|
        WeiboComment.create(
          :weibo_comment_id => comment['idstr'],
          :text => comment['text'],
          :weibo_user_id => comment['user']['idstr'],
          :weibo_status_id => comment['status']['idstr']
        )
      end
    end
  end
  # end of store_comments

 
end
