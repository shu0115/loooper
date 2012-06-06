class Group < ActiveRecord::Base
  attr_accessible :name, :user_id

  belongs_to :user
  has_many :members, :dependent => :delete_all
  has_many :items

  #------------#
  # delete_ok? #
  #------------#
  # グループ削除許可判定
  def delete_ok?( user )
    return false unless self.user_id == user.id
    return false if self.name == user.screen_name
    return true
  end

  private

  #---------------------#
  # self.create_default #
  #---------------------#
  # デフォルトグループ作成
  def self.create_default( user )
    # デフォルトグループが存在しなければ
    unless Group.where( user_id: user.id, name: user.screen_name ).exists?
      group = Group.create( user_id: user.id, name: user.screen_name )
      Member.create( user_id: user.id, group_id: group.id )
    end
  end

end