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

			describe 'GET /items/:id' do
				it 'can get one item by its id' do
					item_id = create(:item).id

					get "/api/v1/items/#{item_id}"

					expect(response).to be_successful

					item = JSON.parse(response.body, symbolize_names: true)

					expect(item[:data][:id]).to eq(item_id)
					expect(item[:data][:attributes]).to have_key(:name)
					expect(item[:data][:attributes]).to have_key(:description)
					expect(item[:data][:attributes]).to have_key(:unit_price)
					expect(item[:data][:attributes]).to have_key(:merchant_id)
				end
			end
		end
	end

	context 'when an item does not exist' do
		describe 'GET /items' do
			it 'returns an error message' do

				get '/api/v1/items'

				items = JSON.parse(response.body, symbolize_names: true )

				expect(response.status).to eq(404)
				expect(items[:errors]).to eq("No Items Found")
			end
		end

		describe 'GET /items/:id' do
			it 'returns an error message' do

				get '/api/v1/items/1'

				item = JSON.parse(response.body, symbolize_names: true )

				expect(response.status).to eq(404)
				expect(item[:errors]).to eq("Item Not Found")
			end
		end
	end

	context "it can create a new item" do
		describe 'POST /item/' do
			it 'creates a new item' do
				@merchant = Merchant.create(:name => 'Bob', :id => 1)

				item_params = ({
					name: 'chair',
					description: 'it is just a chair',
					unit_price: 999.99,
					merchant_id: 1
				})
				headers = {"CONTENT_TYPE" => "application/json"}

				post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)

				created_item = Item.last
				expect(response).to be_successful
				expect(created_item.name).to eq(item_params[:name])
				expect(created_item.description).to eq(item_params[:description])
				expect(created_item.unit_price).to eq(item_params[:unit_price])
				expect(created_item.merchant_id).to eq(item_params[:merchant_id])
			end
		end
	end

	context 'it can update existing items' do
		describe 'PATCH /item/' do
			context 'it can successfully update existing items' do
				it 'updates the item' do
					item = create(:item)
					previous_item_name = Item.last.name
					item_params = { name: "New Item" }
					headers = { "CONTENT_TYPE" => "application/json" }

					patch "/api/v1/items/#{item.id}", headers: headers, params: JSON.generate({item: item_params})
					response_body = JSON.parse(response.body, symbolize_names: true)
					item = Item.find_by(id: item.id)

					expect(response).to be_successful
					expect(item.name).to eq("New Item")
					expect(item.name).to_not eq(previous_item_name)
				end
			end

			context "it cannot update an existing item" do
				it 'returns an error' do
					item = create(:item)
					previous_item_name = Item.last.name
					item_params = { name: "" }
					headers = { "CONTENT_TYPE" => "application/json" }
					
					patch "/api/v1/items/#{item.id}", headers: headers, params: JSON.generate({item: item_params})
					response_body = JSON.parse(response.body, symbolize_names: true)
					item = Item.find_by(id: item.id)
					
					expect(response).to_not be_successful
					expect(response.status).to eq(404)
					expect(item.name).to eq(previous_item_name)
					expect(item.name).to_not eq("New Item")
					expect(response_body[:errors]).to eq("Unable to update item")
				end
			end
		end
		
		context "it can delete an item" do
			describe "DESTROY /items/:id" do
				it 'should delete an item' do
					merchant = create(:merchant)
					customer = create(:customer)

					item = create(:item, merchant_id: merchant.id)
					item_2 = create(:item, merchant_id: merchant.id)

					invoice_1 = create(:invoice, merchant_id: merchant.id, customer_id: customer.id)
					invoice_2 = create(:invoice, merchant_id: merchant.id, customer_id: customer.id)
					
					invoice_item_1 = create(:invoice_item, invoice_id: invoice_1.id, item_id: item.id, quantity: 2)
					invoice_item_2 = create(:invoice_item, invoice_id: invoice_2.id, item_id: item.id, quantity: 4)
					invoice_item_3 = create(:invoice_item, invoice_id: invoice_1.id, item_id: item_2.id, quantity: 3)
					
					expect(Item.count).to eq(2)
					expect(Invoice.count).to eq(2)
					expect(InvoiceItem.count).to eq(3)
					expect(Merchant.count).to eq(1)

					delete "/api/v1/items/#{item.id}"

					expect(response).to be_successful
					expect(response.status).to eq(204)
					expect{Item.find(item.id)}.to raise_error(ActiveRecord::RecordNotFound)
					expect(Item.count).to eq(1)
					expect(Invoice.count).to eq(1)
					expect(InvoiceItem.count).to eq(1)
				end
			end

			context 'when the item does not exist' do
				it 'sends an error message' do
					merchant = create(:merchant)
					customer = create(:customer)
	
					item = create(:item, merchant_id: merchant.id)
					item_2 = create(:item, merchant_id: merchant.id)
	
					invoice_1 = create(:invoice, merchant_id: merchant.id, customer_id: customer.id)
					invoice_2 = create(:invoice, merchant_id: merchant.id, customer_id: customer.id)
					
					invoice_item_1 = create(:invoice_item, invoice_id: invoice_1.id, item_id: item.id, quantity: 2)
					invoice_item_2 = create(:invoice_item, invoice_id: invoice_2.id, item_id: item.id, quantity: 4)
					invoice_item_3 = create(:invoice_item, invoice_id: invoice_1.id, item_id: item_2.id, quantity: 3)
					
					expect(Item.count).to eq(2)
					expect(Invoice.count).to eq(2)
					expect(InvoiceItem.count).to eq(3)
					expect(Merchant.count).to eq(1)
	
					delete "/api/v1/items/#{Item.last.id+1}"
					response_body = JSON.parse(response.body, symbolize_names: true)
	
					expect(response).to_not be_successful
					expect(response.status).to eq(404)
					expect(response_body[:errors]).to eq("Unable to find item with id")
					expect(Item.count).to eq(2)
					expect(Invoice.count).to eq(2)
					expect(InvoiceItem.count).to eq(3)
					expect(Merchant.count).to eq(1)
				end
			end
		end
	end
end