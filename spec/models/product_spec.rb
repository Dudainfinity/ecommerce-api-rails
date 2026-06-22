require 'rails_helper'

RSpec.describe Product, type: :model do
  it "is valid with valid attributes" do
    expect(build(:product)).to be_valid
  end

  it "requires a unique sku" do
    create(:product, sku: "ABC-1")
    expect(build(:product, sku: "ABC-1")).not_to be_valid
  end

  it "rejects negative prices" do
    expect(build(:product, price: -1)).not_to be_valid
  end

  it "rejects negative stock" do
    expect(build(:product, stock: -5)).not_to be_valid
  end

  it "knows whether it has enough stock" do
    product = build(:product, stock: 10)
    expect(product.in_stock?(10)).to be(true)
    expect(product.in_stock?(11)).to be(false)
  end

  it "filters active products with the .active scope" do
    create(:product, active: true)
    create(:product, active: false)
    expect(Product.active.count).to eq(1)
  end
end
