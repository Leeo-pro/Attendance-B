class OverWorkEndTimeToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :over_work_end_time, :datetime
    add_column :attendances, :overwork_next, :text
  end
end
