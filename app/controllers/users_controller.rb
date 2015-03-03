class UsersController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
	add_breadcrumb "Dashboard", :root_path
	add_breadcrumb "Collaborators", :users_path
  before_action :set_user, only: [:resend_confirmation]

	def index
   	@users = User.order("first_name, last_name ASC").includes(:role)
    
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
    respond_to do |format|
      if @user.save
        format.html { redirect_to users_path, notice: 'User was successfully created.' }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
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

    @projects = Project.all.includes (:client)
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
    @user = User.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:first_name, :last_name, :role_id,:team_id, :email,:qr_code, :pin_code)
  end

  def user_project_params
    params.require(:user).permit(user_projects_attributes: [:id, :project_id, :_destroy])
  end
end