class Order < ApplicationRecord
  enum :status, { pending: 0, paid: 1, shipped: 2, delivered: 3, cancelled: 4 }

  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  accepts_nested_attributes_for :order_items

  validates :status, presence: true
  validates :total, numericality: { greater_than_or_equal_to: 0 }
  validate :must_have_items, on: :create

  # Roda depois que os order_items aninhados são validados (e o unit_price é definido),
  # então o total reflete o preço congelado de cada item.
  after_validation :calculate_total

  def calculate_total
    self.total = order_items.reject(&:marked_for_destruction?).sum do |item|
      (item.unit_price || 0) * (item.quantity || 0)
    end
  end

  private

  def must_have_items
    errors.add(:order_items, "must have at least one item") if order_items.empty?
  end
end
