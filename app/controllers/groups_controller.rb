# coding: utf-8
class GroupsController < ApplicationController

  #-------#
  # index #
  #-------#
  def index
    @groups = Group.where( user_id: session[:user_id] ).order( "created_at DESC" ).includes( :user ).all
    @group = Group.new
  end

  #------#
  # show #
  #------#
  def show
    @group = Group.where( id: params[:id], user_id: session[:user_id] ).includes( :members => :user ).first
  end

=begin
  #-----#
  # new #
  #-----#
  def new
    @group = Group.new

    @submit = "create"
  end
=end

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

end
