class ChangeDataOverWorkEndTimeToAttendance < ActiveRecord::Migration[5.1]
  def change
    remove_column :attendances, :over_work_end_time, :time
  end
end
