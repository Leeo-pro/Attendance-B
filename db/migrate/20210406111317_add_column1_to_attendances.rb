class AddColumn1ToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :apply_month, :date
  end
end
