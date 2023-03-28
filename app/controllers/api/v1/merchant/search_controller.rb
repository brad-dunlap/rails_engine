class Api::V1::Merchant::SearchController < ApplicationController
	def index
		merchants = Merchant.search_by_name(params[:name])
		render json: MerchantSerializer.new(merchants)
	end
end