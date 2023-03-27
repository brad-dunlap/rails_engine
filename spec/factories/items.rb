FactoryBot.define do
	factory :item do
		name { Faker::Commerce.product_name }
		description { Faker::Commerce.product_description }
		unit_price { Faker::Commerce.price }
		association :merchant
	end
end