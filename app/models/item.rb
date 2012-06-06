# coding: utf-8
class Item < ActiveRecord::Base
  attr_accessible :last_done_at, :life, :name, :user_id, :status, :archive_at, :group_id

  belongs_to :user
  has_many :histries
  belongs_to :group

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
  def cancel_ok?( user )
    # 最新履歴のユーザIDが一致しなければ
    history = History.where( item_id: self.id ).order( "done_at DESC" ).first
    return false unless history.user_id == user.id

    # 最新履歴以外に履歴が存在しなければ
    unless History.where( item_id: self.id ).where( "id != #{history.id}" ).count > 0
      return false
    end

    return true
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
