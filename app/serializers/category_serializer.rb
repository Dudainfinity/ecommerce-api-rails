class CategorySerializer
  include JSONAPI::Serializer

  attributes :name, :description, :created_at

  attribute :products_count do |category|
    category.products.size
  end
end
