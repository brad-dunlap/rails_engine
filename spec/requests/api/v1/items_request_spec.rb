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

			describe 'GET /items/:id' do
				it 'can get one item by its id' do
					item_id = create(:item).id.to_s

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

	context "it cannot create a new item" do
		describe 'POST /item/' do
			it 'returns error if uable to create' do
				merchant = Merchant.create(:name => 'Bob', :id => 1)

				item_params = ({
					name: 'chair',
					description: 'it is just a chair',
					merchant_id: merchant.id
				})
				headers = {"CONTENT_TYPE" => "application/json"}

				post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)

				expect(response).to_not be_successful
				expect(response.status).to eq(422)
				expect(response.body).to include("Unable to create item - missing required parameters")
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
	

	context 'it can return merchant data' do
		describe 'GET /items/:id/merchant' do
			it 'returns merchant data' do

				merchant1 = create(:merchant)
				merchant2 = create(:merchant)
				item = create(:item, merchant_id: merchant1.id)

				get "/api/v1/items/#{item.id}/merchant"

				merchant_data = JSON.parse(response.body, symbolize_names: true)

				expect(response).to be_successful
				expect(merchant_data).to have_key(:data)

				expect(merchant_data[:data]).to have_key(:id)
				expect(merchant_data[:data][:id]).to be_a(String)

				expect(merchant_data[:data]).to have_key(:attributes)
				expect(merchant_data[:data][:attributes]).to have_key(:name)
				expect(merchant_data[:data][:attributes][:name]).to be_a(String)
			end
		end
	end

	describe 'find one item by name' do
		context 'if item is found' do
			it 'returns the first object in an array that is in alphabetical order' do
				merchant = create(:merchant)
				item_1 = create(:item, name: "stuffed dog", description: "its a doggy", merchant_id: merchant.id)
				item_2 = create(:item, name: "cat litter", description: "cover the smell", merchant_id: merchant.id)
				item_3 = create(:item, name: "dog bowl", description: "cute dog bowl", merchant_id: merchant.id)

				get "/api/v1/items/find?name=dog"

				data = JSON.parse(response.body, symbolize_names: true)

				expect(response).to be_successful
				expect(data).to have_key(:data)
				expect(data[:data]).to have_key(:id)
			end
		end

		context 'if item not is found' do
			it 'returns an error message' do
				merchant = create(:merchant)
				item_1 = create(:item, name: "stuffed dog", description: "its a doggy", merchant_id: merchant.id)
				

				get "/api/v1/items/find?name=fish"

				data = JSON.parse(response.body, symbolize_names: true)

				expect(response).to be_successful
				expect(data).to have_key(:data)
				expect(data[:data]).to_not have_key(:id)
				expect(data[:data][:errors]).to include("no results found")
			end
		end
	end

	describe 'find one object by min or max price' do
		context 'if item is found' do
			it 'returns the first item that is greater than or equal to the minimum price' do
				merchant = create(:merchant)
				item1 = create(:item, name: "Batman", unit_price: 100, merchant_id: merchant.id)
				item2 = create(:item, name: "Joker", unit_price: 200, merchant_id: merchant.id)
				item3 = create(:item, name: "Catwoman", unit_price: 300, merchant_id: merchant.id)

				get "/api/v1/items/find?min_price=150"

				data = JSON.parse(response.body, symbolize_names: true)

				expect(response).to be_successful

				expect(data).to have_key(:data)
				expect(data[:data]).to have_key(:id)

				item = data[:data]

				expect(item).to have_key(:attributes)
				expect(item[:attributes]).to have_key(:name)
				expect(item[:attributes][:name]).to eq(item3.name)

				expect(item[:attributes]).to have_key(:description)
				expect(item[:attributes][:description]).to eq(item3.description)

				expect(item[:attributes]).to have_key(:unit_price)
				expect(item[:attributes][:unit_price]).to eq(item3.unit_price)

				expect(item[:attributes]).to have_key(:merchant_id)
				expect(item[:attributes][:merchant_id]).to eq(item3.merchant_id)
			end

			it 'returns the first item that is less than or equal to the maximum price' do
				merchant = create(:merchant)
				item1 = create(:item, name: "Batman", unit_price: 100, merchant_id: merchant.id)
				item2 = create(:item, name: "Joker", unit_price: 200, merchant_id: merchant.id)
				item3 = create(:item, name: "Catwoman", unit_price: 300, merchant_id: merchant.id)

				get "/api/v1/items/find?max_price=250"

				data = JSON.parse(response.body, symbolize_names: true)

				expect(response).to be_successful

				expect(data).to have_key(:data)
				expect(data[:data]).to have_key(:id)

				item = data[:data]

				expect(item).to have_key(:attributes)
				expect(item[:attributes]).to have_key(:name)
				expect(item[:attributes][:name]).to eq(item1.name)

				expect(item[:attributes]).to have_key(:description)
				expect(item[:attributes][:description]).to eq(item1.description)

				expect(item[:attributes]).to have_key(:unit_price)
				expect(item[:attributes][:unit_price]).to eq(item1.unit_price)

				expect(item[:attributes]).to have_key(:merchant_id)
				expect(item[:attributes][:merchant_id]).to eq(item1.merchant_id)
			end
		end

		context 'if object is not found' do
			describe 'search is less than 0' do
				it 'returns an error message' do
					merchant = create(:merchant)
					item1 = create(:item, name: "Batman", unit_price: 100, merchant_id: merchant.id)
					item2 = create(:item, name: "Joker", unit_price: 200, merchant_id: merchant.id)
					item3 = create(:item, name: "Catwoman", unit_price: 300, merchant_id: merchant.id)

					get "/api/v1/items/find?min_price=-1"

					expect(response).to_not be_successful
					expect(response.body).to include("price cannot be negative")
				end
			end

			describe 'no matches found' do
				it 'returns an error message' do
					merchant = create(:merchant)
					item1 = create(:item, name: "Batman", unit_price: 100, merchant_id: merchant.id)
					item2 = create(:item, name: "Joker", unit_price: 200, merchant_id: merchant.id)
					item3 = create(:item, name: "Catwoman", unit_price: 300, merchant_id: merchant.id)

					get "/api/v1/items/find?min_price=101&max_price=199"

					expect(response).to_not be_successful
					expect(response.body).to include("no matches found")
				end
			end

			describe 'cannot send name with price' do
				it 'returns an error message if a user searches for both name and price' do
					merchant = create(:merchant)
					item1 = create(:item, name: "Batman", unit_price: 100, merchant_id: merchant.id)
					item2 = create(:item, name: "Joker", unit_price: 200, merchant_id: merchant.id)
					item3 = create(:item, name: "Catwoman", unit_price: 300, merchant_id: merchant.id)

					get "/api/v1/items/find?name=dog&min_price=100"

					expect(response).to_not be_successful
					expect(response.status).to eq(400)
					expect(response.body).to include("cannot send name with price")

				end
			end
		end
	end
end