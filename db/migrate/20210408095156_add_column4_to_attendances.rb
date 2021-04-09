class AddColumn4ToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :before_started_at, :datetime
    add_column :attendances, :before_finished_at, :datetime
    add_column :attendances, :after_started_at, :datetime
    add_column :attendances, :after_finished_at, :datetime
  end
end
