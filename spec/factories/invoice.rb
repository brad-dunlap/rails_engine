FactoryBot.define do
	factory :invoice do
		status { Faker::Lorem.word}
	end
end