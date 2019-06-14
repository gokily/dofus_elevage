class MountsController < ApplicationController
  before_action :authenticate_user!
  before_action :correct_user?, only: [:edit, :update]

  def index
    @mounts = current_user.mounts.paginate(page: params[:page], per_page: 15)
  end

  def new
    @mount = current_user.mounts.build
  end

  def create
    @mount = current_user.mounts.build(mount_params)
    @mount.pregnant = false
    if @mount.save
      flash[:success] = "New mount added!"
      redirect_back(fallback_location: mounts_path)
    else
      flash[:danger] = "Didn't work!"
      redirect_back(fallback_location: mounts_path)
    end
  end

  def edit
    @mount = current_user.mounts.find(params[:id])
  end

  def update
    @mount = current_user.mounts.find(params[:id])
    if @mount.update_attributes(mount_params)
      flash[:success] = 'Mount edited'
      redirect_back(fallback_location: @mount)
    else
      render 'edit'
    end
  end

  def birth
    @mounts = current_user.mounts.where(pregnant: true).paginate(page: params[:page])
  end

  private
  def mount_params
    params.require(:mount).permit(:name, :color, :sex, :reproduction, :pregnant)
  end

  def correct_user?
    @mount = current_user.mounts.find_by(id: params[:id])
    redirect_to mounts_path if @mount.nil?
  end
end
