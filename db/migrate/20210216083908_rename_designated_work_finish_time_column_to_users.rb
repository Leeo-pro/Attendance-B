class RenameDesignatedWorkFinishTimeColumnToUsers < ActiveRecord::Migration[5.1]
  def change
    rename_column :users, :designated_work_finish_time, :designated_work_end_time
  end
end
