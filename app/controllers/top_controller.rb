# coding: utf-8
class TopController < ApplicationController

  #-------#
  # index #
  #-------#
  def index
    # ログイン済みであればリダイレクト
    unless session[:user_id].blank?
      redirect_to( controller: "loop_items" )
    end
  end

end
