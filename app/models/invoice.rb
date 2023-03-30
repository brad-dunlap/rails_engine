class Invoice < ApplicationRecord
  has_many :invoice_items, dependent: :destroy
  has_many :items, through: :invoice_items, dependent: :destroy
  has_many :transactions, dependent: :destroy
  belongs_to :merchant

	def one_item?
		self.items.size <= 1
	end
end