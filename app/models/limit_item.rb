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
    print "[ created_at ] : " ; p (deadline - created_at).to_i ;
    print "[ rest_date ] : " ; p rest_date.to_i ;
    print "[ パーセント ] : " ; p (rest_date.to_f / (deadline - created_at).to_f) ;

    return rest_date
  end

  #------------------#
  # show_percent_bar #
  #------------------#
  # 消化率バーを表示する
  def show_percent_bar( rest_date )
    show_bar = ""
    created_date = Date.new( self.created_at.year, self.created_at.month, self.created_at.day )
    deadline = Date.new( self.deadline.year, self.deadline.month, self.deadline.day )
    rest_bar = ((rest_date.to_f / (deadline - created_date).to_f) * 10).to_i

    (10 - rest_bar).times{ |i| show_bar += "■" }  # 消化日数率
    rest_bar.times{ |i| show_bar += "□" }         # 残日数率

    return show_bar
  end

end
