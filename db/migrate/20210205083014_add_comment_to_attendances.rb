class AddCommentToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overwork, :string
    add_column :attendances, :person, :string
  end
end
