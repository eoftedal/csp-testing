class CreateResults < ActiveRecord::Migration
  def change
    create_table :results do |t|
      t.string :useragent
      t.string :results
      t.integer :total
      t.integer :success

      t.timestamps
    end
  end
end
