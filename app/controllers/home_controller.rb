# encoding: utf-8
class HomeController < ApplicationController
  before_action :authenticate_user!
  add_breadcrumb "Dashboard", :root_path 
  def index
  end

end
