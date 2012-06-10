# coding: utf-8
class Item < ActiveRecord::Base
  attr_accessible :last_done_at, :life, :name, :user_id, :status, :archive_at, :group_id

  belongs_to :user
  has_many :histories, :dependent => :delete_all
  belongs_to :group

  # ----- scope ----- #
  # アーカイブ以外
  scope :not_archive, lambda{ where( "status != 'archive'" ) }

  #---------------#
  # get_rest_life #
  #---------------#
  # 残ライフを返す
  def get_rest_life
    return 0 if self.last_done_at.blank?

    days = ( Time.now - self.last_done_at ).divmod( 24 * 60 * 60 )
    rest_life = self.life.to_i - days[0]

    return rest_life
  end

  #-----------#
  # is_owner? #
  #-----------#
  def is_owner?( user )
    return true if self.user_id == user.id
    return false
  end

  #------------#
  # cancel_ok? #
  #------------#
  def cancel_ok?( user, histories )
    histories.sort!{ |a, b| b.done_at <=> a.done_at }
    last_history = histories.last

    # 最新履歴のユーザIDが一致しなければ
    return false unless last_history.user_id == user.id

    # 最新履歴以外に履歴が存在しなければ
    unless histories.length >= 2
      return false
    end

    return true
  end

  #-----------------#
  # self.show_gauge #
  #-----------------#
  # ゲージを表示する
  def self.show_gauge( rest )
    if rest > 0
      return "■"
    elsif rest < 0
      return "×"
    end
  end

  private

end
