class ItemsController < ApplicationController

  layout 'basic', only: :new
  
  before_action :get_current_item, only: [:show, :edit, :update, :destroy]

  # レイアウトはnewとcreateのとき変更する

  def index
    #ひとまず固定で以下アイテムの取得をする
    #孫カテゴリーIDの一覧取得
    def get_categoryid(ancestor_id) 
      parente_id = Category.find(ancestor_id).find_all_by_generation(2)
      array = parente_id .ids
    end
    #出品中のアイテムIDの絞り込み
    def get_transaction_status(transaction_ids,ids)
      item_test = transaction_ids & ids
    end

    #出品中のアイテムのIDを取得する
      transaction_ids = Transaction.where(transaction_status: 1).pluck(:item_id)

    #レディース新着のアイテム取得  
      ids = Item.where(category_id:get_categoryid(1)).pluck(:id)
      @ladies  = Item.where(id:get_transaction_status(transaction_ids,ids)).order("created_at DESC").limit(10).includes(:item_images)
    #メンズ新着アイテムの取得
      ids = Item.where(category_id:get_categoryid(2)).pluck(:id)
      @mens  = Item.where(id:get_transaction_status(transaction_ids,ids)).order("created_at DESC").limit(10).includes(:item_images)
    #家電・スマホ・カメラ新着アイテムの取得
      ids = Item.where(category_id:get_categoryid(8)).pluck(:id)
      @appliances  = Item.where(id:get_transaction_status(transaction_ids,ids)).order("created_at DESC").limit(10).includes(:item_images)
    #おもちゃ・ホビー・グッズ新着アイテムの取得
      ids = Item.where(category_id:get_categoryid(6)).pluck(:id)
      @hobbies  = Item.where(id:get_transaction_status(transaction_ids,ids)).order("created_at DESC").limit(10).includes(:item_images)
  #人気のブランド取得
    #シャネル新着アイテムの取得
      ids = Item.where(brand_id: 1).pluck(:id)
      @chanels = Item.where(id:get_transaction_status(transaction_ids,ids)).order("created_at DESC").limit(10).includes(:item_images)
    #ルイヴィトン新着アイテムの取得
      ids = Item.where(brand_id: 3).pluck(:id)
      @louises = Item.where(id:get_transaction_status(transaction_ids,ids)).order("created_at DESC").limit(10).includes(:item_images)
    #シュプリーム新着アイテムの取得
      ids = Item.where(brand_id: 4).pluck(:id)
      @supremes = Item.where(id:get_transaction_status(transaction_ids,ids)).order("created_at DESC").limit(10).includes(:item_images)
    #ナイキ新着アイテムの取得
      ids = Item.where(brand_id: 2).pluck(:id)
      @nikes = Item.where(id:get_transaction_status(transaction_ids,ids)).order("created_at DESC").limit(10).includes(:item_images)
      
  end

  def new
    @item = Item.new
    @item.item_images.build
  end

  def get_category_children
    #選択された親カテゴリーに紐付く子カテゴリーの配列を取得
    @category_children = Category.find_by(category_name: "#{params[:parent_name]}", parent_id: nil).children
  end

  # 子カテゴリーが選択された後に動くアクション
  def get_category_grandchildren
    #選択された子カテゴリーに紐付く孫カテゴリーの配列を取得
    @category_grandchildren = Category.find("#{params[:child_id]}").children
  end

  def get_category_size
    category = Category.find(params[:grandchild_id])
    @sizes = []
    category.category_sizes.each do |size|
      @sizes << size.size
    end
  end

  def create
    @item = Item.new(item_params)
    if @item.valid?
      if @item.save!
        params[:item_images][:image_url].each do |a|
          @item.item_images.create!(image_url: a)
        end
          Transaction.create(buyer_id: current_user.id,
            seller_id: current_user.id,
            item_id: @item.id,
            grade_by_buyer_id: 2,
            grade_by_seller_id: 2,
            transaction_status: 1,#１、出品中、２は取引中、３は売却済
            payment_method_id: 1)  
        redirect_to items_path, notice: '商品を出品しました'
      end
    else
      if @item[:item_images].blank?
        flash[:item_images] = '画像がありません'
      end
      if @item[:name].blank?
        flash[:name] = '入力してください'
      end
      if @item[:description].blank?
        flash[:description] = '入力してください'
      end
      if @item[:category_id].blank?
        flash[:category_id] = '選択してください'
      end
      if @item[:item_condition_id].blank?
        flash[:item_condition_id] = '選択してください'
      end
      if @item[:ship_fee_bearer_id].blank?
        flash[:ship_fee_bearer_id] = '選択してください'
      end
      if @item[:delivery_method_id].blank?
        flash[:delivery_method_id] = '選択してください'
      end
      if @item[:prefecture_id].blank?
        flash[:prefecture_id] = '選択してください'
      end
      if @item[:days_before_ship_id].blank?
        flash[:days_before_ship_id] = '選択してください'
      end
      if @item[:price].blank? or @item[:price] < 300 or @item[:price] > 9999999
        flash[:price] = '300以上9999999以下で入力してください'
      end
      if @item[:price] == 0 or item_params[:price].include?('.') == true
        flash[:price] = '整数で入力してください'
      end
      
      # バリデーション失敗時のアクション
      redirect_to action: 'new', layout: 'basic'
    end
  end

  def edit
    render layout: 'basic'
  end

  def update
    if @item.update!(item_params)
      # 成功時の処理
    end
    redirect_to item_path
  end

  def destroy
    item = Item.find(params[:id])
    if current_user.id == item.user_id && item.destroy
      redirect_to items_path, notice: '出品した商品を削除しました'
    else
      flash.now[:alert] = '商品を削除できませんでした'
      render :index
    end
  end

  def show
    user_id = @item.user_id
    @items = Item.where(user_id: user_id).includes(:item_images)
    brand_id = @item.brand_id
    @itembs = Item.where(brand_id: brand_id).includes(:item_images)
  end

  private
  def item_params
    params.require(:item).permit(:name, :description, :price, :item_condition_id, :ship_fee_bearer_id, :prefecture_id, :days_before_ship_id, :delivery_method_id, :brand_id, :category_id, :size_id, item_images_attributes: [:image_url, :item_id]).merge(user_id: 1) # current_user.id
  end

  # 現在のアイテムをインスタンス変数@itemに格納する
  def get_current_item
    @item = Item.includes(:category, :user, :item_images).find(params[:id])  # , :brand, :size, :item_condition, :ship_fee_bearer, :delivery_method, :days_before_ship
  end
end
