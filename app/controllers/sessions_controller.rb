# coding: utf-8
class SessionsController < ApplicationController

  #----------#
  # callback #
  #----------#
  def callback
    auth = request.env["omniauth.auth"]
    user = User.where( provider: auth["provider"], uid: auth["uid"] ).first || User.create_with_omniauth( auth )
    session[:user_id] = user.id

    # デフォルトグループ作成
    Group.create_default( user )

    redirect_to( { controller: "loop_items" }, notice: "ログインしました。" )
  end

  #---------#
  # destroy #
  #---------#
  def destroy
    session[:user_id] = nil

    redirect_to :root, notice: "ログアウトしました。"
  end

  #---------#
  # failure #
  #---------#
  def failure
    render text: "<span style='color: red;'>Auth Failure</span>"
  end

end