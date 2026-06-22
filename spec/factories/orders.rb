FactoryBot.define do
  factory :order do
    user
    status { :pending }

    # Build with at least one item so it passes the `must_have_items` validation.
    transient do
      product { nil }
      quantity { 1 }
    end

    after(:build) do |order, evaluator|
      product = evaluator.product || build(:product)
      # Leave unit_price nil so the model derives it from the product price.
      order.order_items << build(:order_item, order: order, product: product, quantity: evaluator.quantity, unit_price: nil)
    end
  end
end
