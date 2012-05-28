# coding: utf-8
class ItemsController < ApplicationController

  #-------#
  # index #
  #-------#
  def index
    @items = Item.where( user_id: session[:user_id] ).all
    @item = Item.new
  end

  #------#
  # show #
  #------#
  def show
    @item = Item.where( id: params[:id], user_id: session[:user_id] ).first
  end

  #-----#
  # new #
  #-----#
  def new
    @item = Item.new
    
    @submit = "create"
  end

  #------#
  # edit #
  #------#
  def edit
    @item = Item.where( id: params[:id], user_id: session[:user_id] ).first
    
    @submit = "update"
  end

  #--------#
  # create #
  #--------#
  def create
    @item = Item.new( params[:item] )
    @item.user_id = session[:user_id]

    if @item.save
      redirect_to( { action: "index" }, notice: "Item was successfully created." )
    else
      render action: "new"
    end
  end

  #--------#
  # update #
  #--------#
  def update
    @item = Item.where( id: params[:id], user_id: session[:user_id] ).first

    if @item.update_attributes( params[:item] )
      redirect_to( { action: "show", id: params[:id] }, notice: "Item was successfully updated." )
    else
      render action: "edit", id: params[:id]
    end
  end

  #---------#
  # destroy #
  #---------#
  def destroy
    @item = Item.where( id: params[:id], user_id: session[:user_id] ).first
    @item.destroy

    redirect_to action: "index"
  end

end
