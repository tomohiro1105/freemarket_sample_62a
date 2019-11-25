module ItemsHelper

  COMMISSION_RATE = 0.1

  # 手数料の計算
  def calc_fm_commission(price)
    return (price * COMMISSION_RATE).floor.to_i
  end

  # 商品販売利益の計算
  def calc_fm_profit(price)
    return price - calc_fm_commission(price)
  end

end
