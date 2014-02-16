class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :current_user

  private

  def current_user
    if User.where(:id => session[:user_id]).count == 0
      if not session[:user_id].nil?
        flash[:notice] = "Your account no longer exists!"
      end
      session[:user_id] = nil
    end
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
end
