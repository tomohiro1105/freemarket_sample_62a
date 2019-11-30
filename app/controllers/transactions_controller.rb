class TransactionsController < ApplicationController
  require 'payjp'
  layout 'users' ## とりあえずここにかいておく。
  def new
    binding.pry
    
  end

  def show
    binding.pry
    @item = Item.find(params[:id])
  end

  def create

  end

  def index
    card = CreditCard.where(user_id: current_user.id).first
    #テーブルからpayjpの顧客IDを検索
    if card.blank?
      #登録された情報がない場合にカード登録画面に移動
      redirect_to controller: "credit_card", action: "new"
    else
      Payjp.api_key = ENV["PAYJP_PRIVATE_KEY"]
      #保管した顧客IDでpayjpから情報取得
      customer = Payjp::Customer.retrieve(card.customer_id)
      #保管したカードIDでpayjpから情報取得、カード情報表示のためインスタンス変数に代入
      @default_card_information = customer.cards.retrieve(card.card_id)
    end
    
    
  end

  def pay
    card = CreditCard.where(user_id: current_user.id).first
    Payjp.api_key = ENV['PAYJP_PRIVATE_KEY']
    Payjp::Charge.create(
    :amount => 13500, #支払金額を入力（itemテーブル等に紐づけても良い）
    :customer => card.customer_id, #顧客ID
    :currency => 'jpy', #日本円
  )
    # Transaction.create({id: current_user.id,buyer_id: current_user.id,seller_id: current_user.id,item_id: 4,grade_by_buyer_id: 2,comment_by_buyer: "aa",grade_by_seller_id: 2,comment_by_seller: "3",transaction_status: 2,payment_method_id: 1})
    # itemの情報を持って来られるようになったら、上記のコメントアウトを外し中身を変更する
    redirect_to action: 'done' #完了画面に移動
  end

  def done
  end

  private
  # 許可するキーを設定
  def transaction_params
    params.require(:transaction).permit(
      :id, :buyer_id, :seller_id, :item_id
    )
  end


end