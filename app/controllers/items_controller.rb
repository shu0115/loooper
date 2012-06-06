# coding: utf-8
class ItemsController < ApplicationController

  #-------#
  # index #
  #-------#
  def index
    @type = params[:type].presence || "mine"

    @items = Item.not_archive.includes( :user, :group )

    if @type == "mine"
      # 自分のアイテムを取得
      @items = @items.where( user_id: session[:user_id] )
    else
      # 所属するグループのアイテムを取得
      group_ids = Member.where( user_id: session[:user_id] ).map{ |m| m.group_id }
      @items = @items.where( group_id: group_ids )
    end

    @item = Item.new( life: 7 )

    # 残ライフが少ない順にソート
    @items.sort!{ |a, b| a.get_rest_life <=> b.get_rest_life }

    # グループ取得(デフォルトグループ／メンバーに紐付くグループ)
    @default_group = Group.where( user_id: session[:user_id], name: current_user.screen_name ).first
    @groups = Member.where( user_id: session[:user_id] ).order( "groups.name ASC" ).includes( :group ).map{ |m| m.group }
  end

  #------#
  # edit #
  #------#
  def edit
    @item = Item.where( user_id: session[:user_id], id: params[:id] ).first
  end

  #--------#
  # create #
  #--------#
  def create
    @item = Item.new( params[:item] )
    @item.user_id = session[:user_id]
    @item.last_done_at = Time.now

    if @item.save
      # 初期Done履歴作成
      History.create( user_id: @item.user_id, item_id: @item.id, done_at: @item.last_done_at )

      redirect_to( { action: "index" } ) and return
    else
      render action: "new" and return
    end
  end

  #--------#
  # update #
  #--------#
  def update
    @item = Item.where( user_id: session[:user_id], id: params[:id] ).first

    if @item.update_attributes( params[:item] )
      redirect_to( { action: "index" }, notice: 'Update!' ) and return
    else
      render action: "edit", id: params[:id] and return
    end
  end

  #---------#
  # destroy #
  #---------#
  def destroy
    @item = Item.where( user_id: session[:user_id], id: params[:id] ).first
    @item.destroy

    redirect_to( action: "index", type: params[:type] ) and return
  end

  #------#
  # done #
  #------#
  def done
    member = Member.where( user_id: session[:user_id], group_id: params[:group_id] ).first

    redirect_to( { action: "index" }, alert: "メンバーに含まれていません。" ) and return if member.blank?

#    item = Item.where( user_id: session[:user_id], id: params[:id] ).first
    item = Item.where( id: params[:id], group_id: member.group_id ).first

    message = Hash.new

    if item.update_attributes( status: "done", last_done_at: Time.now )
      # Done履歴作成
      History.create( user_id: session[:user_id], item_id: item.id, group_id: item.group_id, done_at: item.last_done_at )

      message[:notice] = "DONE!!!"
    else
      message[:alert] = "ERROR!!!"
    end

    redirect_to( { action: "index", type: params[:type] }, message ) and return
  end

  #---------#
  # archive #
  #---------#
  def archive
    item = Item.where( user_id: session[:user_id], id: params[:id] ).first

    unless item.update_attributes( status: "archive", archive_at: Time.now )
      alert = "Archive Error."
    end

    redirect_to( { action: "index", type: params[:type] }, alert: alert ) and return
  end

  #--------#
  # cancel #
  #--------#
  def cancel
    member = Member.where( user_id: session[:user_id], group_id: params[:group_id] ).first

    redirect_to( { action: "index" }, alert: "メンバーに含まれていません。" ) and return if member.blank?

    message = Hash.new
    item = Item.where( id: params[:id], group_id: member.group_id ).first
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

    redirect_to( { action: "index", type: params[:type] }, message ) and return
  end

end
