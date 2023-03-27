require 'rails_helper'

describe 'Items API' do
	context 'when an item exists' do
		describe 'GET /items' do
			it 'returns a list of items' do
				create_list(:item, 3)

				get '/api/v1/items'

				expect(response).to be_successful

				items = JSON.parse(response.body, symbolize_names: true)

				expect(items[:data].size).to eq(3)

				items[:data].each do |item|
					expect(item).to have_key(:id)
					expect(item[:id]).to be_an(Integer)

					expect(item[:attributes]).to have_key(:name)
					expect(item[:attributes][:name]).to be_a(String)

					expect(item[:attributes]).to have_key(:description)
					expect(item[:attributes][:description]).to be_a(String)

					expect(item[:attributes]).to have_key(:unit_price)
					expect(item[:attributes][:unit_price]).to be_a(Float)

					expect(item[:attributes]).to have_key(:merchant_id)
					expect(item[:attributes][:merchant_id]).to be_an(Integer)
				end
			end
		end
	end
end