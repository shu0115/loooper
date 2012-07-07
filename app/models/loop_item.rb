# coding: utf-8
class LoopItem < Item

  #-----------#
  # get_class #
  #-----------#
  def get_class
    rest_life = self.get_rest_life

    return "dead" if rest_life == 0
    return "do_now" if rest_life <= Settings.limit_day
    return "loop_item"
  end

end
