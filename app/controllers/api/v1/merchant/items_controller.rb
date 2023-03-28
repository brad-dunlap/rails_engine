class Api::V1::Merchant::ItemsController < ApplicationController
  def index

		if Merchant.find(params[:merchant_id]).items.exists?			
			render json: ItemSerializer.new(Merchant.find(params[:merchant_id]).items)
		else
			render json: { errors: "Merchant Item not found" }, status: 404
		end
  end
end