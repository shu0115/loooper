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

    @not_member_users = User.where( "id NOT IN ( #{member_ids.join(',')} )" ).order( "created_at DESC" ).page( params[:page] ).per( 50 ).all
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

end
