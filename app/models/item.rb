# coding: utf-8
class Item < ActiveRecord::Base
  attr_accessible :last_done_at, :life, :name, :user_id, :status, :archive_at

  belongs_to :user

  # アーカイブ以外
  scope :not_archive, lambda{ where( "status != 'archive'" ) }

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
    if rest_life > 0
      return "■"
    elsif rest_life < 0
      return "×"
    end
  end

end
