class MountsController < ApplicationController
  before_action :authenticate_user!
  before_action :correct_user?, only: [:edit, :update, :mate]

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

  def pregnant
    @mounts = current_user.mounts.where(pregnant: true).paginate(page: params[:page])
  end

  def breed
    @mount = current_user.mounts.find(params[:id])
    @mates = current_user.mounts.where(sex: @mount.sex == 'F' ? 'M' : 'F', pregnant: false).paginate(page: params[:page])
  end

  def mate
    parent1 = current_user.mounts.find_by(id: params[:id])
    parent2 = current_user.mounts.find_by(id: params[:parent2])
    if parent1.mate(parent2) == 1
      flash[:success] = "#{parent1.name} mated with #{parent2.name}."
      redirect_to(mounts_path)
    else
      flash[:danger] = "Cannot mate #{parent1.name} with #{parent2.name}."
      redirect_back(fallback_location: breed_mount_path(parent1.id))
    end
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
