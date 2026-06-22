FactoryBot.define do
  factory :order_item do
    order
    product
    quantity { 1 }
    unit_price { 99.90 }
  end
end
