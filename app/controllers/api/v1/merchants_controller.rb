class Api::V1::MerchantsController < ApplicationController
	def index
		@merchants = Merchant.all

		render json: {
			data: @merchants.map do |merchant|
				{
					id: merchant.id,
					type: 'merchant',
					attributes: {
						name: merchant.name
					}
				}
			end
		}
	end

	def show
		if Merchant.exists?(params[:id])
			@merchant = Merchant.find(params[:id])
				render json: {
					data: {
						id: @merchant.id,
						type: 'merchant',
						attributes: {
							name: @merchant.name
						}
					}
				}
		else
			render json: { errors: "Merchant not found" }, status: 404
		end				
	end
end