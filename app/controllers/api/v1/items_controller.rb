class Api::V1::ItemsController < ApplicationController
  def index

		if Merchant.find(params[:merchant_id]).items.exists?
			@merchant = Merchant.find(params[:merchant_id])
			@items = @merchant.items
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
		else
			render json: { errors: "Merchant Item not found" }, status: 404
		end
  end
end