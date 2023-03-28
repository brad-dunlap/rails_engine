require 'rails_helper'

RSpec.describe Item, type: :model do
  describe 'relationships' do
    it { should belong_to(:merchant) }
    it { should have_many(:invoice_items) }
    it { should have_many(:invoices).through(:invoice_items) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:merchant_id) }
    it { should validate_presence_of(:unit_price) }
    it { should validate_numericality_of(:unit_price) }
  end

  describe 'class methods' do
    describe ":search_by_name" do
      it 'returns the first item by alphabetical order, with case-insensitive and partial search parameter matches' do
				merchant = create(:merchant)
				item_1 = create(:item, name: "stuffed dog", description: "its a doggy", merchant_id: merchant.id)
				item_2 = create(:item, name: "cat litter", description: "cover the smell", merchant_id: merchant.id)
				item_3 = create(:item, name: "dog bowl", description: "cute dog bowl", merchant_id: merchant.id)

				expect(Item.search_by_name("dog")).to eq(item_3)
      end
		end

		describe ":search_by_price" do
			it "returns the first item matching the min price search, alphabetically" do
				merchant = create(:merchant)
				item1 = create(:item, name: "Batman", unit_price: 100, merchant_id: merchant.id)
				item2 = create(:item, name: "Joker", unit_price: 200, merchant_id: merchant.id)
				item3 = create(:item, name: "Catwoman", unit_price: 300, merchant_id: merchant.id)

				expect(Item.search_by_price(150, nil)).to eq(item3)
			end

			it "returns the first item matching the max price search, alphabetically" do
				merchant = create(:merchant)
				item1 = create(:item, name: "Batman", unit_price: 100, merchant_id: merchant.id)
				item2 = create(:item, name: "Joker", unit_price: 200, merchant_id: merchant.id)
				item3 = create(:item, name: "Catwoman", unit_price: 300, merchant_id: merchant.id)

				expect(Item.search_by_price(nil, 250)).to eq(item1)
			end
			it "returns the first item matching both the min and max price search, alphabetically" do
				merchant = create(:merchant)
				item1 = create(:item, name: "Batman", unit_price: 100, merchant_id: merchant.id)
				item2 = create(:item, name: "Joker", unit_price: 200, merchant_id: merchant.id)
				item3 = create(:item, name: "Catwoman", unit_price: 300, merchant_id: merchant.id)
				item4 = create(:item, name: "Mr Freeze", unit_price: 400, merchant_id: merchant.id)

				expect(Item.search_by_price(150, 350)).to eq(item3)
			end
		end
	end
end