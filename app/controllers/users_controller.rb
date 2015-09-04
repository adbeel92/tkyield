class UsersController < DashboardController
  load_and_authorize_resource
  add_breadcrumb "Dashboard", :dashboard_path
  add_breadcrumb "Collaborators", :users_path
  before_action :set_user, only: [:resend_confirmation, :archive_user]

  def index
    @teams = current_account.teams.order("name")
    @users_without_team = current_account.users.active.without_team.includes(:role).order("first_name, last_name")
  end

  def archives
    add_breadcrumb "Archives", :archives_users_path
    @teams = current_account.teams.order("name")
    @users_without_team = current_account.users.archived.without_team.includes(:role).order("first_name, last_name")
  end

  def archive
    @success = @user.archive! ? true : false
  end

  def unarchive
    @success = @user.unarchive! ? true : false
  end 

  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
    add_breadcrumb "Edit", :edit_user_path
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    @user.account = current_account
    if @user.save
      redirect_to users_path, notice: 'User was successfully created.'
    else
      render :new
    end
  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to users_path, notice: 'User was successfully updated.' }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def projects
    add_breadcrumb "Assign Projects", :show_user_project_user_path

    @projects = current_account.projects.includes(:client)
    @grouped_options = @projects.inject({}) do |options, project|
      (options[project.client_name] ||= []) << [project.name, project.id]
      options
    end
  end

  def update_projects
    respond_to do |format|
      if @user.update(user_project_params)
        format.html { redirect_to show_user_project_user_path(@user), notice: 'Projects assigned successfully.' }
      else
        format.html { redirect_to show_user_project_user_path(@user), alert: 'Duplicate assigned project(s)' }
      end
    end
  end

  def resend_confirmation
    @user.send_confirmation_instructions
    redirect_to users_path, notice: "Email sent successfully"
  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = current_account.users.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:avatar, :first_name, :last_name, :role_id, :team_id, :email, :archived_at)
  end

  def user_project_params
    params.require(:user).permit(user_projects_attributes: [:id, :project_id, :_destroy])
  end

end