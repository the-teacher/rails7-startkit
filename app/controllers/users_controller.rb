# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!, except: :profile

  def profile; end

  def update
    # binding.pry
    current_user.update(user_params)
    redirect_to profile_user_path, notice: 'Avatar is uploaded'
  end

  private

  def user_params
    params.require(:user).permit(:avatar)
  end
end
