class Api::BaseApiController < ApplicationController
  skip_before_filter :verify_authenticity_token
  prepend_before_filter :get_auth_token
  respond_to :json

  private
  def get_auth_token
    if auth_token = params[:auth_token].blank? && request.headers["X-Devise-Token"]
      params[:auth_token] = auth_token
    end
  end
end