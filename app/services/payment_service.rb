class PaymentService

	require 'securerandom'
	require 'digest'
	require 'net/http'
	require 'uri'

	def initialize(pg_order_id, pg_amount, pg_description)
		@order_id = pg_order_id
		@amount = pg_amount
		@description = pg_description

		@pg_merchant_id = ENV["MERCHAND_ID"]
		@secret_key = ENV["PAYMENT_SECRET_KEY"]
		@user_id = ENV["USER_ID"]
	end

	def initialize_payment
		request = generate_payment_request
		response = send_request(request)
		handle_response(response)
	end

	private

	def generate_payment_request
		request = build_request
		request['pg_sig'] = generate_signature(request)
		request
	end

	def build_request
		{
			'pg_order_id' => @order_id,
			'pg_merchant_id' => @pg_merchant_id,
			'pg_amount' => @amount,
			'pg_description' => @description,
			'pg_salt' => SecureRandom.hex(8),
			'pg_payment_route' => 'frame',
			'pg_currency' => 'KZT',
			'pg_request_method' = 'POST',
			'pg_success_url' = 'https://procash.kz/payment_success',
			'pg_failure_url' = 'https://procash.kz/payment_failure',
			'pg_user_id' => @user_id
		}
	end

	def generate_signature[request]
		flat_request = make_flat_params_array(request)
		sorted_request = flat_request.sort.to_h
		data = ['init_payment.php'] + sorted_request.values + [@secret_key]
		Digest::MD5.hexdigest(data.join(';'))
	end

	def make_flat_params_array(params, parent_name = '')
		flat_params = {}
		params.each_with_index do |(key, value), index|
			name = "#{parent_name}#{key}#{format('%03d', index + 1)}"
			if value.is_a?(Hash) || value.is_a?(Array)
				flat_params.merge!(make_flat_params_array(value, name))
			else
				flat_params[name] = value.to_s
			end
		end
		flat_params
	end

	# Отправка запроса на сервер FreedomPay
	def send_request(request_params)
		uri = URI.parse(ENV['PAYMENT_URL'])
		request = Net::HTTP::Post.new(uri)
		request.set_form_data(request_params)

		Net::HTTP.start(uri.hostname, uri.post, use_ssl: uri.scheme = 'https') do |http|
			http.request(request)
		end
	end

	# Обработка ответа от сервера
	def handle_response(response)
		if response.is_a?(Net::HTTPSuccess)
			puts "Успешный ответ: #{response.body}"
			response.body
		else
			puts "Ошибка: #{response.code} - #{response.message}"
			{error: "#{response.code} - #{response.message}"}
		end
	end

end
