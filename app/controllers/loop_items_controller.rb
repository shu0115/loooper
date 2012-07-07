# coding: utf-8
class LoopItemsController < ApplicationController

  #-------#
  # index #
  #-------#
  def index
    # グループ取得(デフォルトグループ／メンバーに紐付くグループ)
    @default_group = Group.default( session[:user_id] ).first

    @groups = Group.get_entry_groups( session[:user_id] )
    @group_id = params[:group_id].presence || @default_group.id

    # アイテム一覧
    @loop_items = LoopItem.not_archive.includes( :user, :group, :histories )

    # グループ指定(指定グループID&自分が所属するグループであること)
    @loop_items = @loop_items.where( "group_id = #{@group_id} AND group_id IN (#{Group.get_entry_group_ids( session[:user_id] ).join(',')})" )
    @loop_items = @loop_items.order( "name ASC" )

    # 新規アイテム
    @loop_item = LoopItem.new( life: 7 )

    # 残ライフが少ない順にソート
    @loop_items.sort!{ |a, b| a.get_rest_life <=> b.get_rest_life }
  end

  #------#
  # edit #
  #------#
  def edit
    @loop_item = LoopItem.where( user_id: session[:user_id], id: params[:id] ).first

    # グループ取得(デフォルトグループ／メンバーに紐付くグループ)
    default_group = Group.default( session[:user_id] ).first
    @groups = Group.get_entry_groups( session[:user_id] )
    @select_group = @loop_item.group_id.blank? ? default_group.id : @loop_item.group_id
  end

  #--------#
  # create #
  #--------#
  def create
    item = LoopItem.new( params[:loop_item] )
    item.user_id = session[:user_id]
    item.last_done_at = Time.now

    if item.save
      # 初期Done履歴作成
      History.create( user_id: item.user_id, item_id: item.id, done_at: item.last_done_at )
    else
      alert = "アイテムの作成に失敗しました。"
    end

    redirect_to( { action: "index", group_id: item.group_id }, alert: alert ) and return
  end

  #--------#
  # update #
  #--------#
  def update
    loop_item = LoopItem.where( user_id: session[:user_id], id: params[:id] ).first

    if loop_item.update_attributes( params[:loop_item] )
      redirect_to( { action: "index" }, notice: 'Update!' ) and return
    else
      redirect_to( { action: "index", id: params[:id] }, alert: "アイテムの更新に失敗しました。" ) and return
    end
  end

  #---------#
  # destroy #
  #---------#
  def destroy
    item = LoopItem.where( user_id: session[:user_id], id: params[:id] ).first
    item.destroy

    redirect_to( action: "index", group_id: item.group_id ) and return
  end

  #------#
  # done #
  #------#
  def done
    member = Member.where( user_id: session[:user_id], group_id: params[:group_id] ).first

    redirect_to( { action: "index" }, alert: "メンバーに含まれていません。" ) and return if member.blank?

    item = LoopItem.where( id: params[:id], group_id: member.group_id ).first

    message = Hash.new

    if item.update_attributes( status: "done", last_done_at: Time.now )
      # Done履歴作成
      History.create( user_id: session[:user_id], item_id: item.id, group_id: item.group_id, done_at: item.last_done_at )

      message[:notice] = "DONE!!!"
    else
      message[:alert] = "ERROR!!!"
    end

    redirect_to( { action: "index", group_id: item.group_id }, message ) and return
  end

  #---------#
  # archive #
  #---------#
  def archive
    item = LoopItem.where( user_id: session[:user_id], id: params[:id] ).first

    unless item.update_attributes( status: "archive", archive_at: Time.now )
      alert = "Archive Error."
    end

    redirect_to( { action: "index", group_id: item.group_id }, alert: alert ) and return
  end

  #--------#
  # cancel #
  #--------#
  def cancel
    member = Member.where( user_id: session[:user_id], group_id: params[:group_id] ).first

    redirect_to( { action: "index" }, alert: "メンバーに含まれていません。" ) and return if member.blank?

    message = Hash.new
    item = LoopItem.where( id: params[:id], group_id: member.group_id ).first
    history = History.where( item_id: item.id, user_id: session[:user_id] ).order( "done_at DESC" ).first

    redirect_to( { action: "index" }, alert: "該当する履歴がありません。" ) and return if history.blank?

    # キャンセル対象が無い場合はボタン自体を非表示とする 2012/06/06 Shun Matsumoto
    # # キャンセル対象History以外のHistoryが一つも無ければリダイレクト
    # unless History.where( item_id: item.id, group_id: member.group_id ).where( "id != #{history.id}" ).count > 0
    #   redirect_to( { action: "index" }, alert: "キャンセル出来る履歴がありません。" ) and return
    # end

    ActiveRecord::Base.transaction do
      # 最新履歴削除
      if history.destroy
        # done_atを一つ戻す
        history = History.where( item_id: item.id, group_id: member.group_id ).order( "done_at DESC" ).first

        if item.update_attributes( status: "", last_done_at: history.done_at )
          message[:notice] = "CANCEL!!!"
        else
          message[:alert] = "ERROR!!!"
        end
      end
    end

    redirect_to( { action: "index", group_id: item.group_id }, message ) and return
  end

end
