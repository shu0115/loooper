# coding: utf-8
class History < ActiveRecord::Base
  attr_accessible :done_at, :item_id, :user_id
  
  belongs_to :user
end
