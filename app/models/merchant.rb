class Merchant < ApplicationRecord
	has_many :items, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :invoice_items, through: :invoices, dependent: :destroy

  validates :name, presence: true 
end
