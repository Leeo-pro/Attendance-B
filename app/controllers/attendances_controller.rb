class AttendancesController < ApplicationController
  include AttendancesHelper
  before_action :set_user, only: [:edit_one_month, :update_one_month, :edit_over_work_day_approval, :update_over_work_day_approval,
                                  :edit_one_month_approval, :update_one_month_approval, 
                                  :edit_one_month_admit, :update_one_month_admit,
                                  :edit_work_record_admit, :update_work_record_admit,
                                  :output]
  before_action :logged_in_user, only: [:update, :edit_one_month]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month]
  before_action :set_one_month, only: [:edit_one_month, :output]
  attr_accessor :collection
  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"
  require 'csv'
  
  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    # 出勤時間が未登録であることを判定します。
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.floor_to(15.minutes))
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.floor_to(15.minutes))
        flash[:info] = "お疲れ様でした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user
  end
  
  def edit_one_month
  end
  
  def update_one_month
    ActiveRecord::Base.transaction do # トランザクションを開始します。
        attendances_params.each do |id, item|
          attendance = Attendance.find(id)

          if attendance.before_started_at.nil? && attendance.started_at.nil?
            attendance.restarted_at = item[:started_at]
          elsif attendance.before_started_at.nil? && attendance.started_at.present?
            attendance.before_started_at = attendance.started_at
          elsif attendance.before_started_at.present? && attendance.started_at.present?
            attendance.before_started_at = attendance.started_at
          end
          if attendance.before_finished_at.nil? && attendance.finished_at.nil?
            attendance.refinished_at = item[:finished_at]
          elsif attendance.before_finished_at.nil? && attendance.finished_at.present?
            attendance.before_finished_at = attendance.finished_at
          elsif attendance.before_finished_at.present? && attendance.finished_at.present?
            attendance.before_finished_at = attendance.finished_at
          end

          if item[:started_at].present? && item[:finished_at].present? && item[:person3].present? 
            attendance.superior_status = "#{item[:person3]}へ勤怠変更申請中"
            attendance.superior_status3 = "申請中"
          end
          attendance.update_attributes!(item)
        end
        flash[:success] = "1ヶ月分の勤怠情報を更新しました。"
        redirect_to user_url(date: params[:date])
    end
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end

  def edit_over_work
    @attendance = Attendance.find(params[:id])
    @user = User.find(@attendance.user_id)
  end
  
  def update_over_work
    @attendance = Attendance.find(params[:id])
    @user = User.find(@attendance.user_id)
  
    unless params[:attendance]['over_work_end_time(4i)'] == "" && params[:attendance]['over_work_end_time(5i)'] == ""
      if params[:attendance][:overwork_next] == "true"
        year = (@attendance.worked_on + 1).year
        month = (@attendance.worked_on + 1).month
        day = (@attendance.worked_on + 1).day 
      else
        year = @attendance.worked_on.year
        month = @attendance.worked_on.month
        day = @attendance.worked_on.day
      end
      hour = params[:attendance]['over_work_end_time(4i)']
      min = params[:attendance]['over_work_end_time(5i)']
      params[:attendance][:over_work_end_time] = Time.new(year, month, day, hour, min, 0,).to_time.to_s
    end

    params[:attendance][:superior_status] = "#{params[:attendance][:person]}へ残業申請中" if params[:attendance][:person].present?
    params[:attendance][:change_status] = "false"
    params[:attendance][:superior_status4] = "申請中"
    params[:attendance][:person3] = params[:attendance][:person]
    
    if params[:attendance][:person].present? && params[:attendance][:over_work_end_time].present?
      @attendance.update_attributes(overwork_params)
      flash[:success] = "申請が完了しました。"
      redirect_to user_url(@user)
      
    else
      flash[:danger] = "残業申請が正しくありません。"
      redirect_to user_url(@user)
    end
  end

  def edit_over_work_day_approval
    @notice_users =  User.where(id: Attendance.where(superior_status4: "申請中", person: @user.name).select(:user_id))
    @attendance_lists = Attendance.where(superior_status4: "申請中", person: @user.name)
    @attendance = Attendance.find(params[:id]) 
  end
  
  def update_over_work_day_approval
    params[:attendance][:attendances].each do |id, item|
      attendance = Attendance.find(id)
      if item[:change_status] == "true"
        attendance.approval_day = Date.current 
        attendance.change_status = item[:change_status]
        attendance.superior_status = "残業申請#{item[:superior_status4]}"
        attendance.superior_status4 = item[:superior_status4]
        attendance.save
        flash[:success] = "承認申請が完了しました"
      else
        flash[:danger] = "承認処理が完了していない申請があります。再度ご確認ください"
      end
    end
        redirect_to user_url(@user, order_sort: 1)

  end 

  def edit_one_month_approval
  end
  
  def update_one_month_approval
    if params[:person2].blank?
      flash[:danger] = "承認先が選択されていません"
    else
     @user = User.find(params[:id])
     @attendance = Attendance.find_by(user_id: params[:id], worked_on: params[:apply_month])
     @attendance.person2 = params[:person2]
     @attendance.apply_month = params[:apply_month]
     @attendance.status = "：#{params[:person2]}へ所属長承認申請中"
     @attendance.superior_status2 = "申請中"
     @attendance.save

     flash[:success] = "承認申請が完了しました"
    end
     redirect_to user_url(@user, order_sort: 1)
  end

  def edit_one_month_admit
    @notice_users =  User.where(id: Attendance.where(superior_status2: "申請中", person2: @user.name).select(:user_id))
    @attendance_lists = Attendance.where(superior_status2: "申請中", person2: @user.name)
    @attendance = Attendance.find(params[:id]) 
  end
  
  def update_one_month_admit
    params[:attendance][:attendances].each do |id, item|
      attendance = Attendance.find(id)
      if item[:change_status2] == "true"
        attendance.approval_day = Date.current 
        attendance.change_status2 = item[:change_status2]
        attendance.superior_status2 = item[:superior_status2]
        attendance.status = "：#{@user.name}#{item[:superior_status2]}"
        attendance.save
        flash[:success] = "承認申請が完了しました"
      else
        flash[:danger] = "承認処理が完了していない申請があります。再度ご確認ください"      
      end    
    end
    redirect_to user_url(@user, order_sort: 1)
  end
  
  def edit_work_record_admit
    @notice_users =  User.where(id: Attendance.where(superior_status3: "申請中", person3: @user.name).select(:user_id))
    @attendance_lists = Attendance.where(superior_status3: "申請中", person3: @user.name)
    @attendance = Attendance.find(params[:id]) 
    
    if params[:started_at].present?
      @attendance.restarted_at = params[:started_at]
    end
    if params[:finished_at].present?
      @attendance.refinished_at = params[:finished_at]
    end
    @attendance.save
  end
  
  def update_work_record_admit
    params[:attendance][:attendances].each do |id, item|
      attendance = Attendance.find(id)
      if item[:change_status] == "true"
        attendance.approval_day = Date.current
        attendance.change_status = item[:change_status]
        attendance.superior_status = "勤怠編集#{item[:superior_status3]}"
        attendance.superior_status3 = item[:superior_status3]
        attendance.save
        flash[:success] = "承認申請が完了しました"
      else
        flash[:danger] = "承認処理が完了していない申請があります。再度ご確認ください"      
      end    
    end
    redirect_to user_url(@user, order_sort: 1)
  end

  def approval_record
  end
  
  def output
    @attendance = Attendance.new
    @attendances = Attendance.where(worked_on: @first_day.to_date.in_time_zone.all_month, user_id: params[:id]).where("superior_status like ?","%承認%")
                             .or(Attendance.where(worked_on: @first_day.to_date.in_time_zone.all_month, user_id: params[:id], superior_status: nil).where.not(finished_at: nil)).order(:worked_on)
    respond_to do |format|
      format.html
      format.csv do |csv|
        send_attendances_csv(@attendances)
      end
    end
  end

private
  # 1ヶ月分の勤怠情報を扱います。
  def attendances_params
    params.require(:user).permit(attendances: [:started_at, :finished_at, :note, :overwork, :person, :over_work_end_time, :person3, :before_started_at, :before_finished_at, :restarted_at, :refinished_at, :approval_day])[:attendances]
  end

  def overwork_params
    params.require(:attendance).permit(:worked_on, :overwork, :overwork_next, :person, :person3, :over_work_end_time, :superior_status, :change_status, :superior_status4)
  end

  def reply_overtime_params
    params.require(:attendance).permit(attendances: [:superior_status, :change_status])[:attendances]
  end

  # beforeフィルター

  # 管理権限者、または現在ログインしているユーザーを許可します。
  def admin_or_correct_user
    @user = User.find(params[:user_id]) if @user.blank?
    unless current_user?(@user) || current_user.admin?
      flash[:danger] = "編集権限がありません。"
      redirect_to(root_url)
    end
  end
  
  def send_attendances_csv(attendances)
    bom = "\uFEFF"
    csv_data = CSV.generate(bom) do |csv|
      column_names = %w(日付 出社 退社)
      csv << column_names
      attendances.each do |attendance|
        
        attendance.started_at.present? ? start_time = l(attendance.started_at, format: :time) : start_time = ""
        attendance.finished_at.present? ? end_time = l(attendance.finished_at, format: :time) : end_time = ""
        column_values = [
          attendance.worked_on,
          start_time,
          end_time,
          ]
      csv << column_values
      end
    end
    send_data(csv_data, filename: "出退勤一覧.csv")
  end
end
