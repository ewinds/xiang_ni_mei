class Api::SessionsController < Api::BaseApiController

  def create
    user_name = params[:user_name]
    password = params[:password]

    if user_name.nil? or password.nil?
      render :status => 400,
             :json => {:message => "The request must contain the user name and password."}, :callback => params[:callback]
      return
    end

    @user=User.find_by_user_name(user_name.downcase)

    if @user.nil?
      logger.info("User #{user_name} failed signin, user cannot be found.")
      render :status => 401, :json => {:message => "Invalid user name or passoword."}, :callback => params[:callback]
      return
    end

    # http://rdoc.info/github/plataformatec/devise/master/Devise/Models/TokenAuthenticatable
    @user.ensure_authentication_token!

    if not @user.valid_password?(password)
      logger.info("User #{user_name} failed signin, password \"#{password}\" is invalid")
      render :status => 401, :json => {:message => "Invalid user name or password."}, :callback => params[:callback]
    else
      render :status => 200,
             :json => {
                 :access_token => @user.authentication_token,
                 :id => @user.id,
                 :user_name => @user.user_name,
                 :nick_name => @user.nick_name}
    end
  end

  def destroy
    @user=User.find_by_authentication_token(params[:auth_token])
    if @user.nil?
      logger.info("Token not found.")
      render :status => 401, :json => {:message => "Invalid token."}
    else
      @user.reset_authentication_token!
      render :status => 200, :json => {:message => "You can leaving now."}
    end
  end
end
