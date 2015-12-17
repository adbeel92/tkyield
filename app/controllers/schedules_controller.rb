class SchedulesController<DashboardController
	add_breadcrumb "Dashboard", :dashboard_path 
	before_action :set_schedule, only: [:show, :set, :unset, :destroy, :edit]
  before_action :get_current_schedule, only: [:create_schedule,:current_schedule]
	before_action :get_schedules, only: [:index, :set, :create, :destroy]


	def index
		add_breadcrumb "Schedules", :schedules_path
	end

	def current_schedule
		add_breadcrumb "Schedules", :current_schedule_schedules_path
	end

	def create_schedule
		@schedule = Schedule.find(params[:id])
		@schedule.update_attributes(schedule_params_without_name)
	end

	def set
    current_user.current_schedule.first.set_finish
    current_user.current_schedule.first.unset! unless current_user.current_schedule.blank?
    @schedule.set!
    @schedule.set_start
	end

	def destroy
		@schedule.destroy
	end

	def create
		s = Schedule.new(schedule_params)
	  s.user_id = current_user.id
	  e = Event.count == 0 ? 1 : Event.last.id + 1
	  7.times do |index|
      i = e + index
	  	s.events.build(id:i, inTime:"10:00 AM", outTime: "11:00 AM"	,day_of_week: index)
	  end
		s.save
	end

	def edit_schedule
		@schedule = Schedule.find(params[:schedule][:id_schedule])
		@schedule.update_attributes(schedule_params)
    redirect_to controller: 'schedules', action: 'index', id: @schedule.id
	end

	def show
	end

	def new		
	end
	
	def edit
		@days = {"Monday" => 0, "Tuesday" => 1, "Wednesday" => 2}
	end

	private
		def schedule_params_without_name
      params.require(:schedule).permit(events_attributes:[:id, :inTime,:outTime,:day_of_week])
    end

    def schedule_params
      params.require(:schedule).permit(:name, events_attributes:[:id, :inTime,:outTime,:day_of_week])
    end

    def set_schedule
    	@schedule = Schedule.find(params[:id])
    end
    
    def get_current_schedule
      @schedule = current_user.schedules.find_by(current: true )
    end
    def get_schedules
      @schedules = current_user.schedules
    end
end