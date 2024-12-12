# app/services/r_keeper_service.rb
require "httparty"

class RKeeperService
	include HTTParty

	def initialize(restaurant_id)
		@restaurant_id = restaurant_id
	end

	def get_table_list
		request_body = {
			"taskType": "GetTableList",
			"params": {
				"sync": {
					"objectId": @restaurant_id,
					"timeout": 220
				}
			}
		}
		make_request(request_body)
	end

	def get_order_list(table_code)
		request_body = {
			"taskType": "GetOrderList",
			"params": {
				"sync": {
				"objectId": @restaurant_id,
				"timeout": 220
				},
				"tableCode": table_code,
				"withClosed": false
			}
		}
		make_request(request_body)
	end

	def get_order(order_guid)
		request_body = {
			"taskType": "GetOrder",
			"params": {
				"sync": {
				"objectId": @restaurant_id,
				"timeout": 220
				},
				"orderGuid": order_guid
			}
    	}
		make_request(request_body)
	end

	def get_empoyees
		request_body = {
			"taskType": "GetEmployees",
			"params": {
				"sync": {
				"objectId": @restaurant_id,
				"timeout": 220
				}
			}
		}

		make_request(request_body)
	end

	def get_restaurant_info
		request_body = {
			"taskType": "GetRestaurantInfo",
			"params": {
				"sync": {
					"objectId": @restaurant_id,
					"timeout": 220
				}
			}
		}

		make_request(request_body)
	end

	private

	def headers
		{
			"Content-Type" => "application/json",
			"AggregatorAuthentication" => ENV["RKEEPER_TOKEN"]
		}
	end

	def make_request(request_body)
		response = self.class.post(ENV["RKEEPER_BASE_URL"], headers: headers, body: request_body.to_json)

		if response.success?
			parsed_response = response.parsed_response
			if parsed_response.dig("error", "agentError")
				{ error: parsed_response["error"]["agentError"]["desc"] }
			elsif parsed_response.dig("error", "wsError")
				{ error: parsed_response["error"]["wsError"]["desc"] }
			else
				parsed_response
			end
		else
			{ error: "Ошибка запроса: #{response.message}" }
		end
	end
end
