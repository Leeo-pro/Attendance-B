class AddColumnToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :change_status2, :boolean
  end
end
