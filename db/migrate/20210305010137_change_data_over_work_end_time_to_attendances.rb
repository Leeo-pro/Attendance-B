class ChangeDataOverWorkEndTimeToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :over_work_end_time, :datetime
  end
end
