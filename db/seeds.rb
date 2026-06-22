# Dados de exemplo (seed) para a API de e-commerce.
# Rode com: bin/rails db:seed   (ou db:setup para criar + migrar + popular)

puts "Cleaning database..."
OrderItem.delete_all
Order.delete_all
Product.delete_all
Category.delete_all
User.delete_all

puts "Creating users..."
User.create!(
  name: "Admin",
  email: "admin@example.com",
  password: "password123",
  role: :admin
)

customer = User.create!(
  name: "Maria Cliente",
  email: "cliente@example.com",
  password: "password123",
  role: :customer
)

puts "Creating categories..."
categories = {
  electronics: Category.create!(name: "Eletrônicos", description: "Gadgets e dispositivos"),
  books:       Category.create!(name: "Livros", description: "Livros físicos e digitais"),
  fashion:     Category.create!(name: "Moda", description: "Roupas e acessórios")
}

puts "Creating products..."
products = [
  { name: "Notebook Pro 14",          price: 7999.90, sku: "ELEC-NB-001", stock: 15,  category: categories[:electronics] },
  { name: "Fone Bluetooth ANC",       price: 599.90,  sku: "ELEC-FN-002", stock: 80,  category: categories[:electronics] },
  { name: "Smartphone X",             price: 3499.00, sku: "ELEC-SP-003", stock: 40,  category: categories[:electronics] },
  { name: "Clean Code",               price: 89.90,   sku: "BOOK-CC-001", stock: 120, category: categories[:books] },
  { name: "The Pragmatic Programmer", price: 99.90,   sku: "BOOK-PP-002", stock: 60,  category: categories[:books] },
  { name: "Camiseta Dev",             price: 79.90,   sku: "FASH-TS-001", stock: 200, category: categories[:fashion] },
  { name: "Moletom Code",             price: 159.90,  sku: "FASH-HD-002", stock: 50,  category: categories[:fashion] }
]

products.each do |attrs|
  Product.create!(attrs.merge(description: "#{attrs[:name]} — produto de demonstração.", active: true))
end

puts "Creating a sample order..."
order = customer.orders.new(status: :pending)
order.order_items.new(product: Product.find_by(sku: "BOOK-CC-001"), quantity: 1)
order.order_items.new(product: Product.find_by(sku: "ELEC-FN-002"), quantity: 2)
order.save!

puts "Done!"
puts "  Users:      #{User.count} (admin@example.com / cliente@example.com — senha: password123)"
puts "  Categories: #{Category.count}"
puts "  Products:   #{Product.count}"
puts "  Orders:     #{Order.count}"
