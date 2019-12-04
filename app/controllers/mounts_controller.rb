class MountsController < ApplicationController
  before_action :authenticate_user!
  before_action :correct_user?, only: %i[show edit update mate birth
                                       breed destroy]
  before_action only: [:birth_create] do
    correct_parents?(params[:children])
  end
  before_action :store_location,
                only: %i[edit breed birth]

  def show
    @ancestors = @mount.ancestors(3)
    @ggpf = %w[FFF FFM FMF FMM]
    @ggpm = %w[MFF MFM MMF MMM]
    @gp = %w[FF FM MF MM]
    @parent = %w[F M]
  end

  def edit; end

  def update
    if @mount.update_attributes(mount_params(@mount.class.to_s.downcase))
      flash[:success] = 'Mount edited.'
      redirect_to stored_location_for(:user)
    else
      render 'edit'
    end
  end

  def destroy
    @mount.destroy
    flash[:success] = 'Mount deleted.'
    redirect_to index_page_of(@mount)
  end

  def breed
    @mount = current_user.mounts.find(params[:id])
    @mates = current_user.mounts.mates(@mount, params[:consang])\
                         .paginate(page: params[:page])

  end

  def mate
    parent1 = @mount
    parent2 = current_user.mounts.find_by(id: params[:parent2])
    if parent1.mate(parent2) == 1
      flash[:success] = "#{parent1.name} mated with #{parent2.name}."
      redirect_to stored_location_for(:user)
    else
      flash[:danger] = "Cannot mate #{parent1.name} with #{parent2.name}."
      redirect_back(fallback_location: breed_mount_path(parent1.id))
    end
  end

  def birth
    @mother = @mount
    @father = current_user.mounts.find_by(id: @mother.current_spouse_id)
    @children = Array.new(params[:n_child].to_i) { current_user.mounts.build }
  end

  def birth_create
    @children = []
    params["children"].each do |_k, child|
      @children << current_user.mounts.build(mount_params2(child))
    end
    unless @children.map(&:valid?).all?
      render_birth_create
      return
    end
    if @children.each(&:save)
      mother = current_user.mounts.find_by(id: @children.first.mother_id)
      mother.update_attributes!(pregnant: false)
      redirect_to stored_location_for(:user), notice: 'Babies successfully added'
    else
      render_birth_create
    end
  end

  private

  def mount_params(type)
    params.require(type.to_sym).permit(:name, :color, :sex, :reproduction, :pregnant,
                                       :father_id, :mother_id, :type)
  end

  def mount_params2(my_params)
    my_params.permit(:name, :color, :sex, :reproduction, :pregnant,
                     :father_id, :mother_id, :type)
  end

  def correct_user?
    @mount = current_user.mounts.find_by(id: params[:id])
    redirect_to home_path if @mount.nil?
  end

  def correct_parents?(my_params)
    father = current_user.mounts.find_by(id: my_params['0'][:father_id])
    mother = current_user.mounts.find_by(id: my_params['0'][:mother_id])
    if father.nil? || mother.nil?
      redirect_to mounts_path
    end
  end

  def store_location
    store_location_for(:user, request.referer)
  end
  def render_birth_create
    @mount = current_user.mounts.find_by(id: @children.first.mother_id)
    @father = current_user.mounts.find_by(id: @mother.current_spouse_id)
    render 'birth'
  end

  def index_page_of(mount)
    mount.class.to_s == 'Dd' ? dds_path : muldos_path
  end

end
