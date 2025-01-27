class ApplicationController < ActionController::Base
  before_action :set_locale
  before_action :set_nonce
  
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def set_nonce
    @nonce = SecureRandom.base64(16) # Генерация случайного nonce
  end
end
