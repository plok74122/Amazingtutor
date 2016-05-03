class TeacherCalendarsController < ApplicationController
  before_action :set_available_section, :only => [:create]
  before_action :set_reservaton_list_params, :only => [:show, :index, :teacher_available, :booked_section]
  skip_before_filter :verify_authenticity_token, :only => [:create]
  def index
    @teacher = User.find(@reservaton_list_params[:id]).teacher
    if @reservaton_list_params[:date] != nil
      begin
        Date.parse(@reservaton_list_params[:date])
      rescue ArgumentError
        date_is_nil('invalid date' , @reservaton_list_params[:id])
      else
        if @reservaton_list_params[:date] > Time.now.to_time.at_beginning_of_day
          @reservation_list = AvailableSection.query_reservation_time_list_by_date(@reservaton_list_params[:id], @reservaton_list_params[:date])
          if @reservation_list.count == 0
            date_is_nil('no available sections' , @reservaton_list_params[:id])
          elsif @reservation_list.count > 0
            @appointments = Appointment.new
            render :index
          end
        elsif @reservaton_list_params[:date] < Time.now.to_time.at_beginning_of_day
          date_is_nil('can not choose day before today' , @reservaton_list_params[:id])
        end
      end
    else
      date_is_nil('choose a day' , @reservaton_list_params[:id])
    end


  end

  def new
    current_user = User.third
    @teacher = current_user.teacher
    if @teacher.nil?
    #   倒回註冊老師頁面
    else

    end
  end

  def create
    current_user = User.third
    start_time = AvailableSection.time_shif_to_half_an_hour(@availabele_section_params[:start].to_time, 'after')
    end_time = AvailableSection.time_shif_to_half_an_hour(@availabele_section_params[:end].to_time, 'before')
    @return_insert_sections = AvailableSection.check_section_insertalbe_and_bluk_insert(start_time, end_time,current_user.id)

  end

  def show
    reservation_list = AvailableSection.query_reservation_time_list_by_date(@reservaton_list_params[:id], @reservaton_list_params[:date])
    render :json => reservation_list.to_json
  end

  def teacher_available_section
    @available_section = AvailableSection.teacher_available_section(params[:teacher_calendar_id])
  end

  def booked_section
    @booked_section = Appointment.booked_section(params[:teacher_calendar_id])
  end

  private

  def set_available_section
    @availabele_section_params = params.permit(:start, :end)
  end

  def set_reservaton_list_params
    @reservaton_list_params = params.permit(:date, :id)
  end

  def date_is_nil(notice,teacher_id)
    flash[:notice] = notice
    @recent_14_days = AvailableSection.recent_14_days(teacher_id)
    render :index_reservation_nothing_can_choose
  end
end
