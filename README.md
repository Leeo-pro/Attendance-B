# 勤怠システムを開発しよう！

これはセレブエンジニアサロンの教材で作られたサンプルアプリケーションです。

## 開発環境

* AWS Cloud9<br>
* Ruby<br>
* Rails<br>
* Git(HTTPSからSSH通信へ変更)
* 


class AttendancesController < ApplicationController
  include AttendancesHelper
  before_action :set_user, only: [:edit_one_month, :update_one_month, :edit_over_work_day_approval, :update_over_work_day_approval]
  before_action :logged_in_user, only: [:update, :edit_one_month]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month]
  before_action :set_one_month, only: :edit_one_month

  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"
  
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
      if params[:attendance][:overwork_next] = 1
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

    params[:attendance][:superior_status] = "申請中" if params[:attendance][:person].present?
    
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
    @notice_users =  User.where(id: Attendance.where(person: @user.name).select(:user_id))
    @attendance_lists = Attendance.where(superior_status: "申請中", person: @user.name)
    @attendance = Attendance.find(params[:id]) 
  end
  
  def update_over_work_day_approval
    
    ActiveRecord::Base.transaction do # トランザクションを開始します。
      
      attendances = Attendance.where(superior_status: "申請中", person: @user.name)
      attendances.each do |attendance|

        if params[:attendance][:change] == "true"
          attendance.update_attributes(reply_overtime_params)
          flash[:success] = "残業申請のお知らせを変更しました"
        end
      end
        redirect_to(root_url)
    end
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to(root_url)
  end 

private
  # 1ヶ月分の勤怠情報を扱います。
  def attendances_params
    params.require(:user).permit(attendances: [:started_at, :finished_at, :note, :overwork, :person, :over_work_end_time])[:attendances]
  end

  def overwork_params
    params.require(:attendance).permit(:worked_on, :overwork, :overwork_next, :person, :over_work_end_time, :superior_status, :change_status)
  end

  def reply_overtime_params
    params.require(:attendance).permit(:superior_status)
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
end
