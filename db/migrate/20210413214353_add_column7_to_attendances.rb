class AddColumn7ToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :superior_status3, :string
    add_column :attendances, :superior_status4, :string
  end
end
