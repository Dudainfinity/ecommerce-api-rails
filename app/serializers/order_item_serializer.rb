class OrderItemSerializer
  include JSONAPI::Serializer

  attributes :quantity, :unit_price

  belongs_to :product

  attribute :product_name do |item|
    item.product&.name
  end

  attribute :subtotal do |item|
    item.subtotal
  end
end
