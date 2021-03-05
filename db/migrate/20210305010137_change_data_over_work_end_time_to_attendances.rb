class ChangeDataOverWorkEndTimeToAttendances < ActiveRecord::Migration[5.1]
  def change
    change_column :attendances, :over_work_end_time, :datetime
  end
end
