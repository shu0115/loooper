# coding: utf-8
class ArchivesController < ApplicationController

  #-------#
  # index #
  #-------#
  def index
    @items = Item.where( user_id: session[:user_id], status: "archive" ).includes( :user ).order( "archive_at DESC" ).limit(1000)
  end

  #---------#
  # restore #
  #---------#
  def restore
    item = Item.where( user_id: session[:user_id], id: params[:id] ).first

    unless item.update_attributes( status: "" )
      alert = "Restore Error."
    end

    redirect_to( { action: "index" }, alert: alert )
  end

end
