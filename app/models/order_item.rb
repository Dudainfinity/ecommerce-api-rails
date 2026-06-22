class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }
  validate :enough_stock

  before_validation :set_unit_price, on: :create

  def subtotal
    (unit_price || 0) * (quantity || 0)
  end

  private

  # Snapshot the product's price at purchase time.
  def set_unit_price
    self.unit_price = product.price if product
  end

  def enough_stock
    return if product.blank? || quantity.blank?

    errors.add(:quantity, "exceeds available stock (#{product.stock})") unless product.in_stock?(quantity)
  end
end
