class OrdersController < ApplicationController

  def index
    render :index
  end

  def show
    restaurant_id = params[:restaurantId]
    number_table = params[:numberTable]

    r_keeper_service = RKeeperService.new(restaurant_id)

    # Первый запрос - GetTableList
    table_list_response = r_keeper_service.get_table_list
    if table_list_response[:error]
      broadcast_error_message(I18n.t("errors.messages.title"), I18n.t("errors.messages.desc"))
      return
    end

    table_code = find_table_code(table_list_response, number_table)
    if table_code.nil?
      broadcast_error_message(I18n.t("errors.messages.title_error"), "Стол с номером #{number_table} не найден")
      return
    end


    # Второй запрос - GetOrderList
    order_list_response = r_keeper_service.get_order_list(table_code)
    if order_list_response[:error]
      broadcast_error_message(I18n.t("errors.messages.title"), I18n.t("errors.messages.desc"))
      return
    end

    order_data = order_list_response.dig("taskResponse", "orders").first
    order_guid = order_data["orderGuid"]
    waiter_id = order_data["waiterId"]
    open_time = order_data["openTime"]

    # Третий запрос - GetOrder
    order_response = r_keeper_service.get_order(order_guid)
    if order_response[:error]
      broadcast_error_message(I18n.t("errors.messages.title"), I18n.t("errors.messages.desc"))
      return
    end

    # Четвертый запрос - GetEmployees
    employees_response = r_keeper_service.get_empoyees
    if employees_response[:error]
      broadcast_error_message(I18n.t("errors.messages.title"), I18n.t("errors.messages.desc"))
      return
    end

    restaurant_info_response = r_keeper_service.get_restaurant_info
    if restaurant_info_response[:error]
      broadcast_error_message(I18n.t("errors.messages.title"), I18n.t("errors.messages.desc"))
      return
    end

    waiter_info = find_employee(employees_response, waiter_id)
    discount = (order_response.dig("taskResponse", "order", "price", "total").to_f * 0.1).to_i
    total_price = discount + order_response.dig("taskResponse", "order", "price", "total").to_i

    render :show, locals: {
      number_table: number_table,
      order_data: order_data,
      status: order_response.dig("taskResponse", "order", "status"),
      products: order_response.dig("taskResponse", "order", "products"),
      comment: order_response.dig("taskResponse", "order", "comment"),
      price: order_response.dig("taskResponse", "order", "price", "total"),
      waiter_info: waiter_info.nil? ? "Админ" : waiter_info.dig("name"),
      discount_result: discount,
      restaurant_info: restaurant_info_response.dig("taskResponse", "restaurant", "name"),
      total_price_result: total_price
    }
  end

  private

  def broadcast_error_message(title, desc)
    render :error, locals: {
      error_message: { title: title, desc: desc }
    }
  end

  def find_table_code(table_list_response, number_table)
    table_list_response.dig("taskResponse", "tables").find { |table| table["name"] == number_table }&.dig("code")
  end
    
  def find_employee(employees_response, waiter_id)
    employees_response.dig("taskResponse", "employees").find { |employee| employee["id"] == waiter_id }
  end

end
