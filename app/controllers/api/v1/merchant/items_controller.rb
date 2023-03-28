class Api::V1::Merchant::ItemsController < ApplicationController
  def index
		merchant_id = params[:merchant_id].to_i
	
		if merchant_id == 0
			render json: { errors: "Invalid merchant ID" }, status: 404
			return
		end
	
		merchant = Merchant.find_by(id: merchant_id)
	
		if merchant && merchant.items.exists?
			render json: ItemSerializer.new(merchant.items)
		else
			render json: { errors: "Merchant item not found" }, status: 404
		end
	end
	
end