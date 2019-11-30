class Item < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions
  belongs_to :item_condition
  belongs_to :ship_fee_bearer
  belongs_to_active_hash :prefecture
  belongs_to :days_before_ship
  belongs_to :delivery_method
  belongs_to :user
  belongs_to :brand, optional: true
  belongs_to :category
  belongs_to :size, optional: true
  has_many :item_images, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy

  accepts_nested_attributes_for :item_images, allow_destroy: true

  validates :name, presence: true
  validates :name, length: { maximum: 40 }
  # validates :item_images, presence: true
  # validate :image_validation
  validates :description, presence: true
  validates :description, length: { maximum: 1000 }
  validates :item_condition_id, presence: true
  validates :ship_fee_bearer_id, presence: true
  validates :prefecture_id, presence: true
  validates :days_before_ship_id, presence: true
  validates :category_id, presence: true
  validates :price, presence: true
  validates :price, numericality: { only_integer: true, greater_than: 299, less_than: 10000000} # 値段が300円以上9,999,999円以下であること

  #
  # ビジネスロジック（カテゴリ）
  #

  # 現在の商品の親カテゴリオブジェクトを返す
  def parent_category
    self.category.parent.parent
  end

  # 現在の商品の子カテゴリオブジェクトを返す
  def child_category
    self.category.parent
  end
  
  # 現在の商品の孫カテゴリオブジェクトを返す
  def grandchild_category
    self.category
  end

  # 親カテゴリの一覧を取得
  def parent_categories
    self.parent_category.self_and_siblings
  end

  # 子カテゴリの一覧を取得
  def child_categories
    self.child_category.self_and_siblings
  end

  # 孫カテゴリの一覧を取得
  def grandchild_categories
    self.grandchild_category.self_and_siblings
  end

  


  #
  # ビジネスロジック（サイズ）
  #

  # 現在の商品が属するカテゴリのサイズ一覧を返す
  def sizes
    self.category.sizes
  end

  # 現在の商品が属するカテゴリがサイズ一覧を持っているか判定
  def has_sizes?
    if self.category.sizes.length != 0
      true
    else
      false
    end
  end

end
