class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info, :edit_basic_all, :edit_over_work_day_approval, :update_over_work_day_approval]
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :edit_basic_info, :update_basic_info, :edit_basic_all]
  before_action :correct_user, only: [:show, :edit]
  before_action :admin_user, only: [:index, :destroy, :edit_basic_info, :update_basic_info, 
                :edit_basic_all, :index_attendance]
  before_action :set_one_month, only: :show
  
  
  def index
    @user = User.new
    @users = User.where.not(id: current_user.id).paginate(page: params[:page], per_page: 20)
    if params[:name].present?
      @users = @users.get_by_name params[:name]
    end
  end
    
  def search
    @users = User.search(params[:search])
  end
    
  def show
    @worked_sum = @attendances.where.not(started_at: nil).count
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "新規作成に成功しました。"
      redirect_to @user
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to users_url
    else
      @users = User.paginate(page: params[:page], per_page: 20)
      render :edit
    end
  end
  
  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end
  
  def edit_basic_info
  end
  
  def update_basic_info
    if @user.update_attributes(basic_info_params)
      flash[:success] = "#{@user.name}の基本情報を更新しました。"
    else
      flash[:danger] = "#{@user.name}の更新は失敗しました。<br>" + @user.errors.full_messages.join("<br>")
    end
    redirect_to users_url
  end
  
  def edit_basic_all
  end
  
  def import
    if params[:file].blank?
      flash[:warning] = "CSVファイルが選択されていません。"
      redirect_to users_url
    else
      
      # fileはtmpに自動で一時保存される
      User.import(params[:file])
      flash[:success] = "ユーザー情報をインポートしました。"
      redirect_to users_url
    end 
  end
  
  def index_attendance
    @now_employee_number = []
    @now_name = []
    User.all.each do |user|
      if user.attendances.any?{|day|
        ( day.worked_on == Date.today &&
          day.started_at.present? &&
          day.finished_at.nil?  )
      }
      
        @now_employee_number.push(user.employee_number)
        @now_name.push(user.name)
      end
    end
  end  
  
  def index_area
  end
  
  private
  
    def user_params
      params.require(:user).permit(:name, :email, :affiliation, :password, :password_confirmation,
                                   :employee_number, :uid, :designated_work_start_time, :designated_work_end_time)
    end

    def basic_info_params
      params.require(:user).permit(:affiliation, :basic_work_time, :work_time,
                                   :employee_number, :uid, :designated_work_start_time, :designated_work_end_time)
    end
end
