FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "Product #{n}" }
    description { Faker::Lorem.sentence }
    price { 99.90 }
    sequence(:sku) { |n| "SKU-#{n}" }
    stock { 50 }
    active { true }
    category
  end
end
