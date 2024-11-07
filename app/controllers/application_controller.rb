class ApplicationController < ActionController::Base
  before_action :set_locale
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end
end
