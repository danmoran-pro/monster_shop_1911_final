class UsersController < ApplicationController
  def new
  end
  
  def show
    if current_user
      @user = current_user
    else
      render file: '/public/404'
    end
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id  
      redirect_to profile_path
      flash[:success] = "You are now registered and logged in"
    else
      flash[:error] = @user.errors.full_messages.to_sentence
      render :new
    end
  end
  
  def edit
    @user = current_user
  end 

  def update
    user = current_user
    # if !User.exists? email_address: params[:email_address]
      user.update(user_params)
      redirect_to profile_path
      flash[:success] = "You have updated your profle!"
    # else 
    #   flash[:error] = "That email address is already in use."
      # redirect_to profile_edit_path
    # end 
  end 
  
  private
  
    def user_params
      params.permit(:name, :address, :city, :state, :zip_code, :email_address, :password)
    end

    # def update_params
    #   params.permit(:name, :address, :city, :state, :zip_code, :email_address)
    # end
end