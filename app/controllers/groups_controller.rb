# coding: utf-8
class GroupsController < ApplicationController

  #-------#
  # index #
  #-------#
  def index
    @groups = Member.where( user_id: session[:user_id] ).includes( :group ).order( "groups.created_at DESC" ).all.map{ |m| m.group }
    #@groups = Group.where( user_id: session[:user_id] ).order( "created_at DESC" ).includes( :user, :members => :user ).all
    @group = Group.new
  end

  #------#
  # show #
  #------#
  def show
    @group = Group.where( id: params[:id] ).includes( :user, :members => :user ).first
    @members = @group.members.sort{ |a, b| a.created_at <=> b.created_at }
    member_ids = @members.map{ |m| m.user_id }

    # 追加可能ユーザ取得
    @not_member_users = User.where( "id NOT IN ( #{member_ids.join(',')} )" ).order( "created_at DESC" ).page( params[:page] ).per( 50 ).all

    # グループ付属アイテム取得
    @items = Item.not_archive.includes( :user, :group )
    @items = @items.where( group_id: @group.id ).all
    @items.sort!{ |a, b| a.get_rest_life <=> b.get_rest_life }

    # アイテム新規作成
    @item = Item.new( life: 7 )
  end

  #------#
  # edit #
  #------#
  def edit
    @group = Group.where( id: params[:id], user_id: session[:user_id] ).first
  end

  #--------#
  # create #
  #--------#
  def create
    @group = Group.new( params[:group] )
    @group.user_id = session[:user_id]

    if @group.save
      # デフォルトメンバー作成(自分)
      Member.create( user_id: @group.user_id, group_id: @group.id )
      message = { notice: "グループの作成が完了しました。" }
    else
      message = { alert: "グループの作成に失敗しました。" }
    end

    redirect_to( { action: "index" }, message )
  end

  #--------#
  # update #
  #--------#
  def update
    @group = Group.where( id: params[:id], user_id: session[:user_id] ).first

    if @group.update_attributes( params[:group] )
      redirect_to( { action: "show", id: params[:id] }, notice: "Group was successfully updated." )
    else
      render action: "edit", id: params[:id]
    end
  end

  #---------#
  # destroy #
  #---------#
  def destroy
    @group = Group.where( id: params[:id], user_id: session[:user_id] ).first
    @group.destroy

    redirect_to action: "index"
  end

  #------------#
  # member_add #
  #------------#
  # メンバー追加
  def member_add
    user_id = params[:user_id]
    group_id = params[:group_id]

    unless Member.create( user_id: user_id, group_id: group_id ).blank?
      message = { notice: "メンバーの追加が完了しました。" }
    else
      message = { alert: "メンバーの追加に失敗しました。" }
    end

    redirect_to( { action: "show", id: group_id }, message )
  end

  #-------------#
  # create_item #
  #-------------#
  def create_item
    @item = Item.new( params[:item] )
    @item.user_id = session[:user_id]
    @item.group_id = params[:group_id]
    @item.last_done_at = Time.now

    if @item.save
      # 初期Done履歴作成
      History.create( user_id: @item.user_id, item_id: @item.id, done_at: @item.last_done_at )
    else
      alert = "ループアイテムの作成に失敗しました。"
    end

    redirect_to( { action: "show", id: params[:group_id] }, alert: alert ) and return
  end

end
