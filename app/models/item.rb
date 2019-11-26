class Item < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions
  has_one :item_condition
  has_one :ship_fee_bearer
  # has_one :prefecture
  belongs_to_active_hash :prefecture
  has_one :days_before_ship
  has_one :delivery_method
  belongs_to :user
  belongs_to :brand, optional: true
  belongs_to :category
  belongs_to :size
  has_many :item_images, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy

  accepts_nested_attributes_for :item_images, allow_destroy: true

  validates :name, presence: true
  validates :name, length: { maximum: 40 }
  validates :description, presence: true
  validates :description, length: { maximum: 1000 }
  validates :item_condition_id, presence: true
  validates :ship_fee_bearer_id, presence: true
  validates :prefecture, presence: true
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

end
