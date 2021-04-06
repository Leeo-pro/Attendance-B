class AddFlagToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :superior_status2, :string
    add_column :attendances, :person2, :string
  end
end
