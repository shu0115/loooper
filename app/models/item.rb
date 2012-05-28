class Item < ActiveRecord::Base
  attr_accessible :last_done_at, :life, :name, :user_id
end
