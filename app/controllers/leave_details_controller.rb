class LeaveDetailsController < ApplicationController
  before_filter :authenticate_user!, :except => [:index]
  before_filter :get_employee
  before_filter :get_leave
  before_filter :set_js_params, :only => [:new]
  
  def index
    redirect_to leaves_path if params[:leave_type].blank? || @leave.nil?
    @leave_details = @leave.leave_details.active.asc if @leave
  end
  
  def new
    redirect_to leaves_path if @employee.leaves.empty?
    @leave_detail = @employee.leave_details.new
  end
  
  def create
    @leave_detail = @employee.leave_details.new(params[:leave_detail])
    if @leave_detail.save
      flash_message(:notice, "#{@leave_detail.leave_type} dated on #{@leave_detail.dated_on} was successfully created.")
      flash_message(:warning, @leave_detail.errors.full_messages) if @leave_detail.errors.any?
      redirect_to leave_details_path(:leave_type => @leave_detail.leave.leave_type)
    else
      flash_message(:error, @leave_detail.errors.full_messages) if @leave_detail.errors.any?
      set_js_params
      render :action => "new"
    end
  end
  
private
  def get_employee
    @employee = current_user.employee
  end
  
  def get_leave
    @leave = @employee.leaves.type(params[:leave_type]).first ||
             @employee.leaves.first
  end
  
  def set_js_params
    leave_range = (@leave.date_from .. @leave.date_to)
    js_params[:day_offs] = @employee.day_offs_within(leave_range)
    js_params[:holidays] = @employee.holidays_within(leave_range)
  end
  
end
