# coding: utf-8
class HistoriesController < ApplicationController

  #-------#
  # index #
  #-------#
  def index
    item_id = params[:item_id]

    histories = History.where( user_id: session[:user_id] ).includes( :user, :item ).order( "done_at DESC" ).limit(1000)

    unless item_id.blank?
      histories = History.where( item_id: item_id )
    end

    @histories = histories.all
  end

end
