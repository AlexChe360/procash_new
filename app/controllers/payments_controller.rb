class PaymentsController < ApplicationController
  def create
    unless params[:amount].present? && params[:description].present?
      render json: { error: 'Missing required parameters' }, status: :unprocessable_entity
      return
    end

    payment_service = PaymentService.new(params[:amount], params[:description])
    response = payment_service.initialize_payment

    puts "response: #{response}"

    if response[:redirect_url]
      redirect_url = response[:redirect_url]

      # Переадресуем пользователя на URL для платежа
      redirect_to redirect_url, allow_other_host: true
    else
      render json: { error: 'Не удалось получить URL для платежа. Повторите попытку.' }, status: :unprocessable_entity
    end
  end

  def result
    payment_status = params[:pg_status]
    payment_id = params[:pg_payment_id]

    if payment_status == 'ok'
      redirect_to payment_success_url
    else
      redirect_to payment_failure_url
    end
  end

  def success
    render 'success'
  end

  def failure
    render 'failure'
  end
end
