# coding: utf-8
class User < ActiveRecord::Base
  attr_accessible :provider, :uid, :name, :screen_name, :image, :token, :secret

  has_many :items
  has_many :histories

  has_many :groups
  has_many :members

  private

  #---------------------------#
  # self.create_with_omniauth #
  #---------------------------#
  def self.create_with_omniauth( auth )
    user = User.new
    user[:provider] = auth["provider"]
    user[:uid] = auth["uid"]

    unless auth["info"].blank?
      user[:name] = auth["info"]["name"]
      user[:screen_name] = auth["info"]["nickname"]
      user[:image] = auth["info"]["image"]
    end

    unless auth["credentials"].blank?
      user.token = auth['credentials']['token']
      user.secret = auth['credentials']['secret']
    end

    user.save

    return user
  end

end