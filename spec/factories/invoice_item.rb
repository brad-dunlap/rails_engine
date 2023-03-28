FactoryBot.define do
  factory :invoice_item do
    quantity { Faker::Number.between(from: 1, to: 10) }
    unit_price { Faker::Commerce.price(range: 1..100.0, as_string: true) }

    association :item
    association :invoice
  end
end
