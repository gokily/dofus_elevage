class DdsController < MountsController
  def new
    @mount = current_user.dds.build
  end

  def index
    case params[:mounts]
    when 'fertile'
      @mounts = current_user.dds.fertile.paginate(page: params[:page], per_page: 15)
      @btn_style = %w[btn-secondary btn-success btn-secondary]
    when 'pregnant'
      @mounts = current_user.dds.pregnant.paginate(page: params[:page], per_page: 15)
      @btn_style = %w[btn-secondary btn-secondary btn-warning]
    else
      @mounts = current_user.dds.paginate(page: params[:page], per_page: 15)
      @btn_style = %w[btn-info btn-secondary btn-secondary]
    end
  end

  def create
    @mount = current_user.dds.build(mount_params('dd'))
    @mount.pregnant = false
    if @mount.save
      flash[:success] = "New mount added!"
      redirect_to dds_path
    else
      render 'new'
    end
  end
  
  def update
    if @mount.update_attributes(mount_params('dd'))
      flash[:success] = 'Mount edited.'
      redirect_back(fallback_location: @mount)
    else
      render 'edit'
    end
  end
end
