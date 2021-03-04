class ChangeDataOverWorkEndTimeToAttendance < ActiveRecord::Migration[5.1]
  def change
    change_column :attendances, :over_work_end_time, :time
  end
end
