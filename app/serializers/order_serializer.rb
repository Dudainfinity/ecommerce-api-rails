class OrderSerializer
  include JSONAPI::Serializer

  attributes :status, :total, :created_at

  belongs_to :user
  has_many :order_items

  attribute :items_count do |order|
    order.order_items.size
  end
end
