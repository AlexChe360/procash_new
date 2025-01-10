class PaymentsController < ApplicationController

	def create
		payment_service = PaymentService.new(params[:order_id], params[:amount], params[:description])
		response = payment_service.initialize_payment

		render json: response
	end
end
