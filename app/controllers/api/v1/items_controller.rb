class Api::V1::ItemsController < ApplicationController
	def index
		items = Item.all
		if items.empty?
			render json: { errors: "No Items Found" }, status: 404
		else
			render json: ItemSerializer.new(items)
		end
	end

	def show
		if Item.exists?(params[:id])
			item = Item.find(params[:id])
			render json: ItemSerializer.new(item)
		else 
			render json: { errors: "Item Not Found" }, status: 404
		end		
	end

	def create
		if item_params[:name].blank? || item_params[:description].blank? || item_params[:unit_price].blank?
			render json: { errors: "Unable to create item - missing required parameters" }, status: :unprocessable_entity
		else
			item = Item.create!(item_params)
			render json: ItemSerializer.new(item), status: :created
		end
	end
	

	def update
		item = Item.find(params[:id])
		item.update(item_params)
		if item.save
			render json: ItemSerializer.new(item)
		else 
			render json: { errors: "Unable to update item" }, status: 404
		end
	end

	def destroy
		if Item.exists?(params[:id])
			item = Item.find(params[:id])		
			item.invoices.each do |invoice|
				if invoice.one_item?
				invoice.destroy
				end
			end
			item.destroy
		else
			render json: { errors: "Unable to find item with id" }, status: 404
		end
	end

	private

	def item_params
		params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
	end
end