class AddColumn3ToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :restarted_at, :datetime
    add_column :attendances, :refinished_at, :datetime
  end
end
