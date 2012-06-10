class Group < ActiveRecord::Base
  attr_accessible :name, :user_id, :default_flag

  belongs_to :user
  has_many :members, :dependent => :delete_all
  has_many :items, :dependent => :delete_all

  # ----- scope ----- #
  # デフォルトグループ
  scope :default, lambda{ |user_id| where( default_flag: true, user_id: user_id ) }

  #------------#
  # delete_ok? #
  #------------#
  # グループ削除許可判定
  def delete_ok?( user )
    return false unless self.user_id == user.id
    return false if self.default_flag == true
    return true
  end

  private

  #-----------------#
  # self.default_id #
  #-----------------#
  # デフォルトグループのグループIDを返す
  def self.default_id( user_id )
    self.default( user_id ).select("id").first.try(:id)
  end

  #---------------------#
  # self.create_default #
  #---------------------#
  # デフォルトグループ作成
  def self.create_default( user )
    # デフォルトグループが存在しなければ
    unless Group.where( user_id: user.id, default_flag: true ).exists?
      # デフォルトグループ作成
      group = Group.create( user_id: user.id, name: user.screen_name, default_flag: true )

      # デフォルトメンバー作成
      Member.create( user_id: user.id, group_id: group.id )
    end
  end

  #-----------------------#
  # self.get_entry_groups #
  #-----------------------#
  def self.get_entry_groups( user_id )
    # 自分がメンバーに登録されているグループ取得
    groups = Member.where( user_id: user_id ).order( "groups.name ASC" ).includes( :group ).map{ |m| m.group }
    return groups
  end

  #--------------------------#
  # self.get_entry_group_ids #
  #--------------------------#
  def self.get_entry_group_ids( user_id )
    # 自分がメンバーに登録されているグループのID取得
    group_ids = Member.where( user_id: user_id ).order( "groups.name ASC" ).includes( :group ).map{ |m| m.group.id }
    return group_ids
  end

end
