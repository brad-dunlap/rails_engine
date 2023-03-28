require 'rails_helper'

RSpec.describe Merchant, type: :model do
  describe 'relationships' do
    it { should have_many(:items) }
    it { should have_many(:invoices) }
    it { should have_many(:invoice_items).through(:invoices) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

	describe 'class methods' do
		describe '#search_by_name' do
			it 'returns all merchants by name alphabetically with search parameters' do
				merchant1 = create(:merchant, name: "Bradley")
				merchant2 = create(:merchant, name: "Alexander")
				merchant3 = create(:merchant, name: "Ashley")
				merchant4 = create(:merchant, name: "Chris")

				expect(Merchant.search_by_name("ley")).to eq([merchant3, merchant1])
			end
		end
	end
end