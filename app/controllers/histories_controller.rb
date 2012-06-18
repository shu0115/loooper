# coding: utf-8
class HistoriesController < ApplicationController

  #-------#
  # index #
  #-------#
  def index
    item_id = params[:item_id]

    histories = History.order( "done_at DESC" ).includes( :user, :item ).page( params[:page] ).per( 100 )

    unless item_id.blank?
      histories = histories.where( item_id: item_id )
    else
      histories = histories.where( user_id: session[:user_id] )
    end

    @histories = histories.all
  end

end
