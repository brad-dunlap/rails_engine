require 'rails_helper'

RSpec.describe Invoice, type: :model do
  describe 'relationships' do
    it { should have_many(:invoice_items) }
    it { should have_many(:items).through(:invoice_items) }
    it { should belong_to(:merchant) }
    it { should have_many(:transactions) }
  end

	describe 'instance methods' do
		describe '#has_items?' do
			it 'returns false if there are one or less items' do	
				merchant = create(:merchant)
				customer = create(:customer)

				item = create(:item, merchant_id: merchant.id)
				item_2 = create(:item, merchant_id: merchant.id)

				invoice_1 = create(:invoice, merchant_id: merchant.id, customer_id: customer.id)
				invoice_2 = create(:invoice, merchant_id: merchant.id, customer_id: customer.id)

				invoice_item_1 = create(:invoice_item, invoice_id: invoice_1.id, item_id: item.id, quantity: 1)
				invoice_item_2 = create(:invoice_item, invoice_id: invoice_2.id, item_id: item.id, quantity: 2)
				invoice_item_3 = create(:invoice_item, invoice_id: invoice_1.id, item_id: item_2.id, quantity: 3)

				expect(invoice_1.items.size).to eq(2)
				expect(invoice_1.has_items?).to eq(false)
				expect(invoice_2.items.size).to eq(1)
				expect(invoice_2.has_items?).to eq(true)
			
			end
		end
	end
end