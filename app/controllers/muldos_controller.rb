class MuldosController < MountsController
  def new
    @mount = current_user.muldos.build
  end

  def index
    case params[:mounts]
    when 'fertile'
      @mounts = current_user.muldos.fertile
      @btn_style = %w[btn-secondary btn-success btn-secondary]
    when 'pregnant'
      @mounts = current_user.muldos.pregnant
      @btn_style = %w[btn-secondary btn-secondary btn-warning]
    else
      @mounts = current_user.muldos
      @btn_style = %w[btn-info btn-secondary btn-secondary]
    end
  end

  def create
    @mount = current_user.muldos.build(mount_params('muldo'))
    @mount.pregnant = false
    if @mount.save
      flash[:success] = "New mount added!"
      redirect_to muldos_path
    else
      render 'new'
    end
  end

  def update
    if @mount.update_attributes(mount_params('muldo'))
      flash[:success] = 'Mount edited.'
      redirect_back(fallback_location: @mount)
    else
      render 'edit'
    end
  end

end
