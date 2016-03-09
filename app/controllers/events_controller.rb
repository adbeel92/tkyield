class EventsController < DashboardController
	before_action :get_schedule, only: [:create, :update, :destroy]
	before_action :get_events, only: :create
	def index
	end

	def new
	end

	def create
		event_log = EventLog.new
		event_log.set_event_data(event_params[:inTime], event_params[:outTime], params[:schedule_id], current_user.id, 
														Chronic.parse('monday', :context => :past).to_date  + params[:event][:day_of_week].to_i,
														params[:event][:launch])
		new_event = Event.new(event_params)
		new_event.schedule_id = params[:schedule_id]
		new_event.day_of_week = params[:event][:day_of_week].to_i
		new_event.last_event_log = event_log.id
		if new_event.valid?
    	flash[:success] = "The event has been saved."
			new_event.save
		else
      flash[:error] = "The event could not be saved."
		end
		@events_duration_array = Event.events_duration_array(@schedule.events)
	end

	def edit
	end

	def update
		@current_event = Event.find(params[:id])
		last_event_log = EventLog.find(@current_event.last_event_log)
		last_event_log.edited = false
		last_event_log.save
		last_day = @current_event.day_of_week.to_date.wday
		event_log = EventLog.new
		event_log.set_event_data(params[:start_event], params[:finish_event], params[:schedule_id], current_user.id,
			                      Chronic.parse('monday', :context => :past).to_date + last_day - 1,
			                      false)
		@current_event.update_attributes({:name=>params[:name_event], :inTime=>params[:start_event], :outTime=>params[:finish_event], :last_event_log=>event_log.id})
		@events_duration_array = Event.events_duration_array(@schedule.events)
	end

	def destroy
		event_to_delete = Event.find(delete_event_params[:event_id])
		EventLog.find(event_to_delete.last_event_log).destroy
		event_to_delete.destroy
		@events_duration_array = Event.events_duration_array(@schedule.events)
	end

	private
		def event_params
			params.require(:event).permit(:name, :inTime, :outTime)
		end
		def get_events
			@events = Event.all
		end
		def get_schedule
			@schedule = Schedule.find(params[:schedule_id])			
		end
		def delete_event_params
			params.require(:delete_event).permit(:event_id)
		end
end