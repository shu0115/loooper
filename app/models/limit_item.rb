# coding: utf-8
class LimitItem < Item
  attr_accessible :deadline, :done_user_id

  #---------------#
  # get_rest_date #
  #---------------#
  # 残日数を返す
  def get_rest_date
    return 0 if self.deadline.blank?

    today = Date.today
    deadline = Date.new( self.deadline.year, self.deadline.month, self.deadline.day )
    rest_date = (deadline - today)

    return rest_date
  end

end
