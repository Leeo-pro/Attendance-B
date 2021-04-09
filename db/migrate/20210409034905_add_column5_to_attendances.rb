class AddColumn5ToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :approval_day, :date
  end
end
