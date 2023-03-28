class Api::V1::ItemsController < ApplicationController
	def index
		@items = Item.all
		if @items.empty?
			render json: { errors: "No Items Found" }, status: 404
		else
			render json: ItemSerializer.new(@items)
		end
	end

	def show
		if Item.exists?(params[:id])
			@item = Item.find(params[:id])
			render json: ItemSerializer.new(@item)
		else 
			render json: { errors: "Item Not Found" }, status: 404
		end		
	end

	def create
		item = Item.create!(item_params)
		render json: ItemSerializer.new(item), status: :created
	rescue ActiveRecord::RecordInvalid
		render json: { errors: "Unable to Create Item" }, status: :unprocessable_entity
	end

	def update
		item = Item.find(params[:id])
		item.update(item_params)
		if item.save
			render json: ItemSerializer.new(item)
		else 
			render json: { errors: "Unable to update item" }, status: 422
		end
	end

	def destroy
		if Item.exists?(params[:id])
			item = Item.find(params[:id])		
			item.invoices.each do |invoice|
				if invoice.has_items?
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