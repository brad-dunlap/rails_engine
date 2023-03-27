class Api::V1::ItemsController < ApplicationController
	def index
		@items = Item.all
		if @items.empty?
			render json: { errors: "No Items Found" }, status: 404
		else
			render json: {
				data: @items.map do |item|
					{
						id: item.id,
						type: 'item',
						attributes: {
							name: item.name,
							description: item.description,
							unit_price: item.unit_price,
							merchant_id: item.merchant_id
						}
					}
				end
			}
		end
	end

	def show
		if Item.exists?(params[:id])
			@item = Item.find(params[:id])
			render json: {
				data: {
					id: @item.id,
					type: 'item',
					attributes: {
						name: @item.name,
						description: @item.description,
						unit_price: @item.unit_price,
						merchant_id: @item.merchant_id
					}
				}
			}
		else 
			render json: { errors: "Item Not Found" }, status: 404
		end		
	end
end