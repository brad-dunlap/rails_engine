class Item < ApplicationRecord
  belongs_to :merchant
  has_many :invoice_items, dependent: :destroy
  has_many :invoices, through: :invoice_items, dependent: :destroy

	validates :name, :description, :merchant_id, presence: true
  validates :unit_price, presence: true, numericality: true 

	def self.search_by_name(search)
		where("name ILIKE ?", "%#{search}%")
		.order(:name)
		.first
	end

	def self.search_by_price(min, max)
		if min != nil && max != nil
			where("unit_price >= ? AND unit_price <= ?", min, max)
			.order(:name)
			.first
		elsif max == nil
			where("unit_price >= ?", "#{min}")
			.order(:name)
			.first
		else min == nil
			where("unit_price <= ?", "#{max}")
			.order(:name)
			.first
		end
	end
end