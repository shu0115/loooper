# coding: utf-8
class History < ActiveRecord::Base
  attr_accessible :done_at, :item_id, :user_id, :group_id

  belongs_to :user
  belongs_to :item
end
