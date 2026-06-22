class Product < ApplicationRecord
  belongs_to :category
  has_many :order_items, dependent: :restrict_with_error

  validates :name, presence: true, length: { maximum: 150 }
  validates :sku, presence: true, uniqueness: { case_sensitive: false }
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :stock, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :active, -> { where(active: true) }
  scope :in_stock, -> { where("stock > 0") }
  scope :search, ->(term) { where("name ILIKE :q OR description ILIKE :q", q: "%#{term}%") if term.present? }

  def in_stock?(quantity = 1)
    stock >= quantity
  end

  def decrement_stock!(quantity)
    update!(stock: stock - quantity)
  end
end
