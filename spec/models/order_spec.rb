require 'rails_helper'

RSpec.describe Order, type: :model do
  it "calculates the total from its items before validation" do
    product = create(:product, price: 50)
    order = build(:order, product: product, quantity: 3)
    order.valid?
    expect(order.total).to eq(150)
  end

  it "is invalid without any items" do
    order = Order.new(user: create(:user), status: :pending)
    expect(order).not_to be_valid
    expect(order.errors[:order_items]).to be_present
  end

  it "sets the item unit_price from the product automatically" do
    product = create(:product, price: 42.5)
    order = create(:order, product: product, quantity: 2)
    expect(order.order_items.first.unit_price).to eq(42.5)
  end
end
