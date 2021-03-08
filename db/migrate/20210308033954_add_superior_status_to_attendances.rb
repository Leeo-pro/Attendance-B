class AddSuperiorStatusToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :superior_status, :string
  end
end
