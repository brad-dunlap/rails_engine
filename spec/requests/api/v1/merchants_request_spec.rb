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
					expect(merchant[:id]).to be_an(Integer)
					
					expect(merchant[:attributes]).to have_key(:name)
					expect(merchant[:attributes][:name]).to be_a(String)
				end
			end
		end
		
		describe 'GET /merchants' do
			it 'can get one merchant by its id' do
				id = create(:merchant).id

				get "/api/v1/merchants/#{id}"

				merchant = JSON.parse(response.body, symbolize_names: true)

				expect(response).to be_successful

				expect(merchant[:data][:id]).to eq(id)
				expect(merchant[:data][:attributes]).to have_key(:name)
				expect(merchant[:data][:attributes][:name]).to be_a(String)
			end
		end
	end

	context 'when a merchant does not exist' do
		describe 'GET /merchants/1' do
			it 'returns a 404 error' do

				get '/api/v1/merchants/1'

				merchant = JSON.parse(response.body, symbolize_names: true )

				expect(response.status).to eq(404)
			end
		end
	end
end