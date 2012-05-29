# coding: utf-8
class Item < ActiveRecord::Base
  attr_accessible :last_done_at, :life, :name, :user_id, :status
  
  belongs_to :user
  
  #---------------#
  # get_rest_life #
  #---------------#
  # 残ライフを返す
  def get_rest_life
    return "" if self.last_done_at.blank?
    
    days = ( Time.now - self.last_done_at ).divmod( 24 * 60 * 60 )
    rest_life = self.life - days[0]
    
    return rest_life
  end
  
  private

  #-----------------#
  # self.show_gauge #
  #-----------------#
  # ゲージを表示する
  def self.show_gauge( rest_life )
    gauge = ""
    
    if rest_life > 0
      rest_life.times{ gauge += "■" }
    elsif rest_life < 0
      rest_life.abs.times{ gauge += "×" }
    end
    
    return gauge
  end

end
