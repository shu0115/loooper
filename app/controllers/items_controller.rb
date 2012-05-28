# coding: utf-8
class ItemsController < ApplicationController

  #-------#
  # index #
  #-------#
  def index
    @items = Item.where( user_id: session[:user_id] ).includes( :user ).all
    @item = Item.new( life: 7 )
    
    # 残ライフが少ない順にソート
    @items.sort!{ |a, b| a.get_rest_life <=> b.get_rest_life }
  end

  #------#
  # edit #
  #------#
  def edit
    @item = Item.where( id: params[:id], user_id: session[:user_id] ).first
  end

  #--------#
  # create #
  #--------#
  def create
    @item = Item.new( params[:item] )
    @item.user_id = session[:user_id]
    @item.last_done_at = Time.now

    if @item.save
      redirect_to( { action: "index" } )
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
      redirect_to( { action: "index" }, notice: 'Update!' )
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

  #------#
  # done #
  #------#
  def done
    @item = Item.where( id: params[:id], user_id: session[:user_id] ).first
    
    @item.update_attributes( status: "done", last_done_at: Time.now )
    redirect_to( { action: "index" }, notice: 'Done!!!' )
  end

end
