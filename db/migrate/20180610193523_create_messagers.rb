class CreateMessagers < ActiveRecord::Migration[5.2]
  def change
    create_table :messagers do |t|

      t.timestamps
    end
  end
end
