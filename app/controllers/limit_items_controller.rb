# coding: utf-8
class LimitItemsController < ApplicationController

  #-------#
  # index #
  #-------#
  def index
    @done_flag = params[:done_flag].presence || "not_done"

    # グループ取得
    @default_group = Group.default( session[:user_id] ).first
    @groups = Group.get_entry_groups( session[:user_id] )
    @group_id = params[:group_id].presence || @default_group.id

    # アイテム一覧
    @limit_items = LimitItem.order( "deadline ASC" ).includes( :user, :group, :histories )

    # グループ指定(指定グループID&自分が所属するグループであること)
    @limit_items = @limit_items.where( "group_id = #{@group_id} AND group_id IN (#{Group.get_entry_group_ids( session[:user_id] ).join(',')})" )

    # Doneフラグ
    if @done_flag == "not_done"
      @limit_items = @limit_items.where( "status != 'done'" )
    else
      @limit_items = @limit_items.where( status: "done" )
    end

    # 新規アイテム
    @limit_item = LimitItem.new( deadline: Time.now )
  end

  #--------#
  # create #
  #--------#
  def create
    limit_item = LimitItem.new( params[:limit_item] )
    limit_item.user_id = session[:user_id]

    unless limit_item.save
      alert = "アイテムの作成に失敗しました。"
    end

    redirect_to( { action: "index", group_id: limit_item.group_id }, alert: alert ) and return
  end

  #------#
  # done #
  #------#
  def done
    member = Member.where( user_id: session[:user_id], group_id: params[:group_id] ).first

    redirect_to( { action: "index", group_id: params[:group_id] }, alert: "メンバーに含まれていません。" ) and return if member.blank?

    # アイテム取得
    limit_item = LimitItem.where( id: params[:id], group_id: member.group_id ).first

    # アイテム更新
    if limit_item.update_attributes( status: "done", last_done_at: Time.now, done_user_id: session[:user_id] )
      redirect_to( { action: "index", group_id: limit_item.group_id }, notice: "完了しました。" ) and return
    else
      redirect_to( { action: "index", group_id: limit_item.group_id }, alert: "完了出来ませんでした。" ) and return
    end
  end

  #--------#
  # cancel #
  #--------#
  def cancel
    # アイテム取得
    limit_item = LimitItem.where( id: params[:id], done_user_id: session[:user_id] ).first

    if limit_item.blank?
      redirect_to( { action: "index", group_id: params[:group_id], done_flag: params[:done_flag] }, alert: "完了をキャンセル出来ませんでした。" ) and return
    end

    # アイテム更新
    if limit_item.update_attributes( status: "", last_done_at: nil )
      redirect_to( { action: "index", group_id: limit_item.group_id, done_flag: params[:done_flag] }, notice: "完了をキャンセルしました。" ) and return
    else
      redirect_to( { action: "index", group_id: limit_item.group_id, done_flag: params[:done_flag] }, alert: "完了をキャンセル出来ませんでした。" ) and return
    end
  end

  #------#
  # edit #
  #------#
  def edit
    @done_flag = params[:done_flag]

    @limit_item = LimitItem.where( user_id: session[:user_id], id: params[:id] ).first

    # グループ取得
    @groups = Group.get_entry_groups( session[:user_id] )
    @group_id = params[:group_id].presence
  end

  #--------#
  # update #
  #--------#
  def update
    limit_item = LimitItem.where( user_id: session[:user_id], id: params[:id] ).first

    if limit_item.update_attributes( params[:limit_item] )
      redirect_to( { action: "index", group_id: limit_item.group_id, done_flag: params[:done_flag] }, notice: "Update!" ) and return
    else
      redirect_to( { action: "edit", id: limit_item.id, group_id: limit_item.group_id, done_flag: params[:done_flag] }, alert: "アイテムの更新に失敗しました。" ) and return
    end
  end

  #--------#
  # delete #
  #--------#
  def delete
    limit_item = LimitItem.where( user_id: session[:user_id], id: params[:id] ).first

    unless limit_item.destroy
      alert = "アイテムの削除に失敗しました。"
    end

    redirect_to( { action: "index", group_id: params[:group_id], done_flag: params[:done_flag] }, alert: alert ) and return
  end

end
