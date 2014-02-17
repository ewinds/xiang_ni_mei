class Api::PasswordsController < Api::BaseApiController
  def update
    @user = User.find_by_authentication_token(params[:auth_token])
    if @user.nil?
      render :status => 401, :json => {:message => "Invalid token."}
    elsif not @user.valid_password?(params[:current_password])
      render :status => 401, :json => {:message => "Invalid password."}
    else
      @user.password = params[:password]
      @user.password_confirmation = params[:password_confirmation]
      if @user.save
        render :status => 200, :json => @user.to_json(except: ['email', 'created_at', 'updated_at'])
      else
        render :status => 500, :json => {:message => "Unable to update user."}
      end
    end
  end
end
