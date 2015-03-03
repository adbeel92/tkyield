module Reports
  class ClientsController < ApplicationController
    before_action :authenticate_user!
    add_breadcrumb "Dashboard", :root_path 
    add_breadcrumb "Reports", :reports_list_path 
    
    def show
      @client = Client.find params[:id]
      add_breadcrumb "Clients", :reports_client_path
      @projects = @client.projects
    end
  end
end