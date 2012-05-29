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
      # 初期Done履歴作成
      History.create( user_id: @item.user_id, item_id: @item.id, done_at: @item.last_done_at )
      
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
    item = Item.where( id: params[:id], user_id: session[:user_id] ).first
    message = Hash.new
    
    if item.update_attributes( status: "done", last_done_at: Time.now )
      # Done履歴作成
      History.create( user_id: item.user_id, item_id: item.id, done_at: item.last_done_at )
      
      message[:notice] = "DONE!!!"
    else
      message[:alert] = "ERROR!!!"
    end
    
    redirect_to( { action: "index" }, message )
  end
  
  #--------#
  # cancel #
  #--------#
  def cancel
    message = Hash.new
    item = Item.where( id: params[:id], user_id: session[:user_id] ).first
    history = History.where( item_id: item.id, user_id: session[:user_id] ).order( "done_at DESC" ).first
    
    ActiveRecord::Base.transaction do
      if history.destroy
        history = History.where( item_id: item.id, user_id: session[:user_id] ).order( "done_at DESC" ).first
        
        if item.update_attributes( status: nil, last_done_at: history.done_at )
          message[:notice] = "CANCEL!!!"
        else
          message[:alert] = "ERROR!!!"
        end
      end
    end
    
    redirect_to( { action: "index" }, message )
  end

end
