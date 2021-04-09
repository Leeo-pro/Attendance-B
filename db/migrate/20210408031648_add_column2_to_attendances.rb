class AddColumn2ToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :person3, :string
  end
end
