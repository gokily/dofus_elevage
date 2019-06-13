class MountsController < ApplicationController
  before_action :authenticate_user!
  #before_action :user_signed_in?

  def index
    @mounts = current_user.mounts.paginate(page: params[:page])
  end

  def new
    @mount = current_user.mounts.build
  end

  def create
    @mount = current_user.mounts.build(mounts_params)
    @mount.pregnant = false
    if @mount.save
      flash[:success] = "New mount added!"
      redirect_back(fallback_location: mounts_path)
    else
      flash[:danger] = "Didn't work!"
      redirect_back(fallback_location: mounts_path)
    end
  end

  private
  def mounts_params
    params.require(:mount).permit(:name, :color, :sex, :reproduction, :pregnant)
  end
end
