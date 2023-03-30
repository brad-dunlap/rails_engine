

class Api::V1::Item::SearchController < ApplicationController
	def show
		if (params[:name] && (params[:min_price] || params[:max_price]))
			render json: ErrorSerializer.invalid_parameters("cannot send name with price"), status: 400
		elsif (params[:name])
			by_name
		else (params[:min] || params[:max])
			by_price
		end
	end
	
	private

	def by_name
		if Item.search_by_name(params[:name]).nil?
			render json: ErrorSerializer.invalid_parameters("no results found")
		else
			render json: ItemSerializer.new(Item.search_by_name(params[:name]))
		end
	end

	def by_price
		if (params[:min_price].to_f < 0) || (params[:max_price].to_f < 0)
			render json: { errors: "price cannot be negative" }, status: 400
		else
			items = Item.search_by_price(params[:min_price], params[:max_price])
			if items.nil?
				render json: ErrorSerializer.no_matches_found("no matches found"), status: 400
			else
				render json: ItemSerializer.new(items)
			end
		end
	end
end