class Item < ApplicationRecord
  belongs_to :merchant
  has_many :invoice_items, dependent: :destroy
  has_many :invoices, through: :invoice_items, dependent: :destroy

	validates :name, :description, :merchant_id, presence: true
  validates :unit_price, presence: true, numericality: true 
end