class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  require 'will_paginate/array'

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :server, :email])
  end
end
