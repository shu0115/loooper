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

    created_at = Date.new( self.created_at.year, self.created_at.month, self.created_at.day )

    return rest_date
  end

  #------------------#
  # show_percent_bar #
  #------------------#
  # 残日数バーを表示する(10日が1ゲージ分)
  def show_percent_bar( rest_date )
    show_bar = ""
    rest_per = (rest_date / 10).to_i
    (10 - rest_per).times{ |i| show_bar += "■" }
    rest_per.times{ |i| show_bar += "□" }

    return show_bar

=begin
    show_bar = ""
    created_date = Date.new( self.created_at.year, self.created_at.month, self.created_at.day )
    deadline = Date.new( self.deadline.year, self.deadline.month, self.deadline.day )
    rest_bar = ((rest_date.to_f / (deadline - created_date).to_f) * 10).to_i

    (10 - rest_bar).times{ |i| show_bar += "■" }  # 消化日数率
    rest_bar.times{ |i| show_bar += "□" }         # 残日数率

    return show_bar
=end
  end

end
