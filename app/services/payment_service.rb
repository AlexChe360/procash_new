require 'securerandom'
require 'digest'
require 'net/http'
require 'uri'

class PaymentService

	@test_mode = false	

	def initialize(pg_amount, pg_description)
		@amount = pg_amount
		@description = pg_description

		@pg_merchant_id = @test_mode ? ENV["TEST_MERCHAND_ID"] : ENV["MERCHAND_ID"]
		@secret_key = @test_mode ? ENV["TEST_PAYMENT_SECRET_KEY"] : ENV["PAYMENT_SECRET_KEY"]
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
		request['pg_sig'] = generate_signature(request) # Генерация подписи и добавление её в запрос
		request
	end

	def build_request
		raise "Missing pg_merchant_id" if @pg_merchant_id.nil? || @pg_merchant_id.empty?
		raise "Missing pg_amount" if @amount.nil? || @amount.to_s.empty?
		raise "Missing pg_description" if @description.nil? || @description.empty?

		{
			'pg_order_id' => "%05d" % rand(100000),
			'pg_merchant_id' => @pg_merchant_id,
			'pg_amount' => @amount,
			'pg_description' => @description,
			'pg_salt' => SecureRandom.hex(8),
			'pg_payment_route' => 'frame',
			'pg_user_id' => @user_id
		}
	end

	def generate_signature(request)
		# Преобразуем параметры в плоский массив
		flat_request = make_flat_params_array(request)

		# Печатаем параметры перед сортировкой
		puts "Flat request: #{flat_request.inspect}"

		# Параметры в правильном порядке для подписи (согласно документации)
		ordered_params = [
			'pg_amount', 'pg_description', 'pg_merchant_id', 'pg_order_id',
			'pg_payment_route', 'pg_salt', 'pg_user_id'
		]

		# Строим строку для подписи с правильным порядком
		data = ['init_payment.php'] + ordered_params.map { |key| flat_request[key] } + [@secret_key]

		# Печатаем строку для подписи
		puts "Data for signature: #{data.join(';')}"

		# Генерация MD5-подписи
		signature = Digest::MD5.hexdigest(data.join(';'))

		# Печатаем подпись для отладки
		puts "Generated signature: #{signature}"

		signature
	end


	def make_flat_params_array(params, parent_name = '')
		flat_params = {}
		params.each_with_index do |(key, value), index|
			# Убираем числовые суффиксы
			name = "#{parent_name}#{key}"
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

		# Логируем тело запроса перед отправкой
		puts "Sending request to #{uri} with body:"
		puts request_params.inspect

		Net::HTTP.start(uri.hostname, uri.port, use_ssl: (uri.scheme == 'https')) do |http|
			response = http.request(request)
			# Логируем ответ от сервера
      		puts "Received response: #{response.body.force_encoding('UTF-8')}"
			http.request(request)
		end
	end

	# Обработка ответа от сервера
	def handle_response(response)
		if response.is_a?(Net::HTTPSuccess)
			puts "Успешный ответ: #{response.body.force_encoding('UTF-8')}"
			
			# Пример парсинга XML-ответа
			require 'nokogiri'
			doc = Nokogiri::XML(response.body)
			pg_status = doc.xpath('//pg_status').text
			pg_payment_id = doc.xpath('//pg_payment_id').text
			pg_redirect_url = doc.xpath('//pg_redirect_url').text
			pg_sig = doc.xpath('//pg_sig').text

			puts "Payment Status: #{pg_status}"
			puts "Payment ID: #{pg_payment_id}"
			puts "Redirect URL: #{pg_redirect_url}"
			puts "Sig: #{pg_sig}"

			{ status: pg_status, payment_id: pg_payment_id, redirect_url: pg_redirect_url, sig: pg_sig }
		else
			puts "Ошибка: #{response.code} - #{response.message}"
			{ error: "#{response.code} - #{response.message}" }
		end
	end


end
