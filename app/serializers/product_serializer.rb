class ProductSerializer
  include JSONAPI::Serializer

  attributes :name, :description, :price, :sku, :stock, :active, :created_at

  belongs_to :category

  attribute :category_name do |product|
    product.category&.name
  end
end
