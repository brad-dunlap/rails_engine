class Api::V1::MerchantsController < ApplicationController
	def index
		@merchants = Merchant.all
		if @merchants.empty?
			render json: { errors: "No Merchants Found" }, status: 404
		else
			render json: MerchantSerializer.new(@merchants)
		end
	end

	def show
		if params[:item_id]
			item = Item.find(params[:item_id])
			merchant = item.merchant
		else
			begin
				merchant = Merchant.find(params[:id])
			rescue ActiveRecord::RecordNotFound
				merchant = nil
			end
		end
	
		if merchant
			render json: MerchantSerializer.new(merchant)
		else
			render json: { errors: "Merchant not found" }, status: 404
		end
	end
end
	