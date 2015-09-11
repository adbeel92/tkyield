class ReportsController < DashboardController
  add_breadcrumb "Dashboard", :dashboard_path 

  def index
    add_breadcrumb "Reports", :reports_path
  end

end