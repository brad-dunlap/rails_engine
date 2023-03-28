require 'rails_helper'

describe 'Merchants API' do
	context 'when a merchant exists' do
		describe 'GET /merchants' do
			it 'returns a list of merchants' do
				create_list(:merchant, 3)

				get '/api/v1/merchants'

				expect(response).to be_successful

				merchants = JSON.parse(response.body, symbolize_names: true)

				expect(merchants[:data].count).to eq(3)

				merchants[:data].each do |merchant|
					
					expect(merchant).to have_key(:id)
					
					expect(merchant[:attributes]).to have_key(:name)
					expect(merchant[:attributes][:name]).to be_a(String)
				end
			end
		end
		
		describe 'GET /merchants/:id' do
			it 'can get one merchant by its id' do
				id = create(:merchant).id
				get "/api/v1/merchants/#{id}"

				merchant = JSON.parse(response.body, symbolize_names: true)

				expect(response).to be_successful

				expect(merchant[:data][:id]).to eq(id.to_s)
				expect(merchant[:data][:attributes]).to have_key(:name)
				expect(merchant[:data][:attributes][:name]).to be_a(String)
			end
		end

		describe 'GET /merchants/:id/items' do
			it 'can get all items for a merchant' do

				merchant = create(:merchant)
				items = create_list(:item, 3, merchant: merchant)

				get "/api/v1/merchants/#{merchant.id}/items"

				items = JSON.parse(response.body, symbolize_names: true)

				expect(response).to be_successful

				expect(items[:data].count).to eq(3)

				items[:data].each do |item|
					expect(item).to have_key(:id)
					expect(item[:id]).to be_an(String)

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

	context 'when a merchant does not exist' do
		describe 'GET /merchants' do
			it 'returns a 404 error' do

				get '/api/v1/merchants'

				merchants = JSON.parse(response.body, symbolize_names: true )

				expect(response.status).to eq(404)
				expect(merchants[:errors]).to eq("No Merchants Found")
			end
		end
		
		describe 'GET /merchants/1' do
			it 'returns a 404 error' do

				get '/api/v1/merchants/1'

				merchant = JSON.parse(response.body, symbolize_names: true )

				expect(response.status).to eq(404)
				expect(response.body).to include("Merchant not found")
			end
		end
	end

	context 'when a merchant exists, but an item does not' do
		describe 'GET /merchants/1/items' do
			it 'returns a 404 error' do

				merchant = create(:merchant)
				get "/api/v1/merchants/#{merchant.id}/items"

				items = JSON.parse(response.body, symbolize_names: true )

				expect(response.status).to eq(404)
				expect(items[:errors]).to eq("Merchant item not found")
			end
		end
	end
end