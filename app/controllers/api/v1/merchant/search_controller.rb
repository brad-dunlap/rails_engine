class Api::V1::Merchant::SearchController < ApplicationController
	def index
		if params[:name]
			render json: MerchantSerializer.new(Merchant.search_by_name(params[:name]))
		else
			render json: { errors: "No results matching your search criteria" }
		end
	end
end