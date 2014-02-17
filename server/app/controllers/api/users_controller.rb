  class Api::UsersController < Api::BaseApiController

  def show
    @user = User.find_by_authentication_token(params[:auth_token])
    if @user.nil?
      logger.info("Token not found.")
      render :status => 401, :json => {:message => "Invalid token."}
    else
      render :status => 200, :json => @user.to_json(except: ['email', 'created_at', 'updated_at'])
    end
  end

  def update
    @user = User.find_by_authentication_token(params[:auth_token])
    if @user.nil?
      render :status => 401, :json => {:message => "Invalid token."}
    elsif @user.update_attributes(params[:user])
      render :status => 200, :json => @user.to_json(except: ['email', 'created_at', 'updated_at'])
    else
      render :status => 500, :json => {:message => "Unable to update user."}
    end
  end
end
